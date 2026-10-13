/*
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2026 Addison Heavner
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* sqrt for the cores with DIVWU and MULHU: the way of s_sqrt.c (see
   rl78_sqrt.h) for a positive normal number. Anything else, and a root
   whose low bits leave the rounding to the last correction, goes to the C
   function.

   The mantissa m, 2^52 <= m < 2^53, times 2^10 or 2^11 (the exponent is
   made even) is H, 2^62 <= H < 2^64. The root of H * 2^64, 64 bits, comes
   in three steps (Zimmermann, "Karatsuba square root"):
     s1, r1 = the 16-bit root of the top half of H and its remainder,
              from a linear estimate and two Newton steps;
     s', r' = the 32-bit root of H: q = (r1 * 2^16 + h1) / (2 * s1),
              s' = s1 * 2^16 + q, r' = remainder * 2^16 + h0 - q^2, and one
              less with r' + 2 * s' + 1 where that is negative;
     s      = s' * 2^32 + q2, q2 = r' * 2^31 / s', by long division with two
              16-bit digits.
   s is the root or one more. Its top 53 bits are the result, rounded up
   where bit 10 is set (a root is never halfway between two doubles); with
   bits 1..9 clear the "one more" could change that, and the C function
   decides.

   In: AX = where the result goes, x at [SP+4].

   The frame, from SP:
      0  H; then the dividend of the long division, with the digits of q2
         taking its upper two words: [4..11] = s
      8  s'
     12  r', 6 bytes
     18  the exponent of the result, less one, in its place
     20  the top word of x as it came
     22  where the result goes
     28  x (24: the return address)  */

	.file	"sqrt_s3.S"

#ifdef __RL78_S3__
	.section .text
	.global	___rl78_sqrt64_asm
	.type	___rl78_sqrt64_asm,@function

___rl78_sqrt64_asm:
	push	ax
	movw	ax,[sp+12]
	push	ax
	subw	ax,#0x0010
	cmpw	ax,#0x7fe0
	skc
	br	$!.L_c			; not a positive normal number
	shrw	ax,5
	addw	ax,#511
	shlw	ax,4
	push	ax
	mov	a,[sp+16]
	mov	x,a
	movw	hl,#1024		; even exponent
	bt	a.4,$1f
	movw	hl,#2048
1:
	mov	a,x
	and	a,#0x0f
	or	a,#0x10
	mov	[sp+16],a
	clrb	a
	mov	[sp+17],a
	subw	sp,#18
	; H = m * HL; DE: what goes into the next word
	movw	ax,hl
	movw	bc,ax
	movw	ax,[sp+28]
	mulhu
	movw	[sp+0],ax
	movw	ax,bc
	movw	de,ax
	movw	ax,hl
	movw	bc,ax
	movw	ax,[sp+30]
	mulhu
	addw	ax,de
	movw	[sp+2],ax
	movw	ax,bc
	movw	de,ax
	movw	ax,hl
	movw	bc,ax
	movw	ax,[sp+32]
	mulhu
	addw	ax,de
	movw	[sp+4],ax
	movw	ax,bc
	movw	de,ax
	movw	ax,hl
	movw	bc,ax
	movw	ax,[sp+34]
	mulhu
	addw	ax,de
	movw	[sp+6],ax

	; s1 from the top word t of H: 0x8000 + (t - 0x4000) * 21 / 32 is at
	; most 4% low, and two Newton steps leave it the root or one more
	subw	ax,#0x4000
	movw	bc,ax
	shrw	ax,1
	movw	de,ax
	movw	ax,bc
	shrw	ax,3
	addw	ax,de
	movw	de,ax
	movw	ax,bc
	shrw	ax,5
	addw	ax,de
	addw	ax,#0x8000
	movw	de,ax
	call	$!.L_newton
	call	$!.L_newton
	; r1 = top half of H - s1 * s1; while it is negative s1 is too large
	movw	ax,de
	movw	bc,ax
	mulhu
	movw	hl,ax
	movw	ax,[sp+4]
	subw	ax,hl
	movw	hl,ax
	movw	ax,[sp+6]
	sknc
	incw	bc
	subw	ax,bc
	bnc	$.L_s1
.L_s1_less:
	decw	de
	movw	bc,ax
	movw	ax,de
	addw	ax,ax
	incw	ax
	xchw	ax,bc			; BC: 2 * s1 + 1 less its bit 16, which is CY
	sknc
	incw	ax
	xchw	ax,bc
	addw	ax,hl
	movw	hl,ax
	movw	ax,bc
	sknc
	incw	ax
	bt	a.7,$.L_s1_less
.L_s1:
	; DE = s1, AX:HL = r1, at most 2 * s1.
	; q = (r1 * 2^15 + h1 / 2) / s1, at most 2^16
	shrw	ax,1
	movw	ax,hl
	rorc	a,1
	xch	a,x
	rorc	a,1
	xch	a,x
	movw	bc,ax
	movw	ax,[sp+2]
	rorc	a,1
	xch	a,x
	rorc	a,1
	xch	a,x
	push	de			; s1; the frame is 2 further away
	movw	hl,#0
	divwu
	nop				; not straight into the next instruction
	movw	hl,ax
	; u = remainder * 2 + (h1 & 1); r' = u * 2^16 + h0 - q^2
	movw	ax,de
	addw	ax,ax
	movw	de,ax
	clrw	ax
	rolwc	ax,1
	subw	ax,bc			; bit 16 of u less bit 16 of q
	movw	[sp+18],ax
	mov	a,[sp+4]
	and	a,#1
	or	a,e
	mov	e,a
	movw	ax,hl
	movw	[sp+10],ax
	movw	ax,[sp+0]
	addw	ax,bc
	movw	[sp+12],ax		; s' = s1 * 2^16 + q
	movw	ax,hl
	movw	bc,ax
	mulhu
	movw	hl,ax
	movw	ax,[sp+2]
	subw	ax,hl
	movw	[sp+14],ax
	movw	ax,de
	sknc
	incw	bc
	subw	ax,bc
	movw	[sp+16],ax
	movw	ax,[sp+18]
	sknc
	decw	ax
	movw	[sp+18],ax
	pop	ax
	mov	a,[sp+17]
	bf	a.7,$.L_s2
	; negative: s' one less, r' 2 * s' + 1 more
	movw	ax,[sp+8]
	subw	ax,#1
	movw	[sp+8],ax
	movw	bc,ax
	movw	ax,[sp+10]
	sknc
	decw	ax
	movw	[sp+10],ax
	xchw	ax,bc
	addw	ax,ax
	incw	ax
	xchw	ax,bc
	rolwc	ax,1
	movw	de,ax
	clrw	ax
	rolwc	ax,1			; X:DE:BC = 2 * s' + 1
	movw	hl,sp
	mov	a,c
	add	a,[hl+12]
	mov	[hl+12],a
	mov	a,b
	addc	a,[hl+13]
	mov	[hl+13],a
	mov	a,e
	addc	a,[hl+14]
	mov	[hl+14],a
	mov	a,d
	addc	a,[hl+15]
	mov	[hl+15],a
	mov	a,x
	addc	a,[hl+16]
	mov	[hl+16],a
.L_s2:
	; q2 = r' * 2^31 / s': the dividend is r' / 2 over bit 0 of r' and 31
	; zeros
	mov	a,[sp+16]
	shr	a,1
	movw	ax,[sp+14]
	rorc	a,1
	xch	a,x
	rorc	a,1
	xch	a,x
	movw	[sp+6],ax
	movw	ax,[sp+12]
	rorc	a,1
	xch	a,x
	rorc	a,1
	xch	a,x
	movw	[sp+4],ax
	clrw	ax
	rorc	a,1
	movw	[sp+2],ax
	clrw	ax
	movw	[sp+0],ax
	movw	hl,sp
	movw	ax,[hl+6]
	cmpw	ax,[hl+10]
	bnz	$1f
	movw	ax,[hl+4]
	cmpw	ax,[hl+8]
	bnz	$1f
	; r' = 2 * s': the quotient would be 2^32 and the correction leaves
	; 2^32 - 1
	movw	ax,#0xffff
	movw	[hl+4],ax
	movw	[hl+6],ax
	br	$2f
1:
	incw	hl
	incw	hl
	call	$!.L_digit
	call	$!.L_digit
2:
	; s is at [SP+4]. With bits 1..9 clear the C function decides.
	movw	ax,[sp+4]
	and	a,#0x03
	xch	a,x
	and	a,#0xfe
	or	a,x
	sknz
	br	$!.L_c_frame
	; the top 53 bits, one more with bit 10 set, and the exponent
	movw	hl,sp
	mov	a,[hl+5]
	mov1	cy,a.2
	movw	de,#0
	sknc
	incw	de
	movw	ax,[hl+4]
	shrw	ax,11
	movw	bc,ax
	movw	ax,[hl+6]
	shlw	ax,5
	addw	ax,bc
	addw	ax,de
	movw	[hl+4],ax
	movw	de,#0
	sknc
	incw	de
	movw	ax,[hl+6]
	shrw	ax,11
	movw	bc,ax
	movw	ax,[hl+8]
	shlw	ax,5
	addw	ax,bc
	addw	ax,de
	movw	[hl+6],ax
	movw	de,#0
	sknc
	incw	de
	movw	ax,[hl+8]
	shrw	ax,11
	movw	bc,ax
	movw	ax,[hl+10]
	shlw	ax,5
	addw	ax,bc
	addw	ax,de
	movw	[hl+8],ax
	movw	de,#0
	sknc
	incw	de
	movw	ax,[hl+10]
	shrw	ax,11
	addw	ax,de
	addw	ax,[hl+18]
	movw	bc,ax
	movw	ax,[hl+22]
	movw	de,ax
	movw	ax,bc
	movw	[de+6],ax
	movw	ax,[hl+4]
	movw	[de],ax
	movw	ax,[hl+6]
	movw	[de+2],ax
	movw	ax,[hl+8]
	movw	[de+4],ax
	addw	sp,#24
	ret

.L_c_frame:
	addw	sp,#20
.L_c:
	pop	ax
	movw	[sp+12],ax		; x as it came
	pop	ax
	br	!!___rl78_sqrt64_c

	; DE = min ((DE + H top half / DE) / 2, 0xffff). The frame is 4
	; further away.
.L_newton:
	push	de
	movw	ax,[sp+12]
	movw	bc,ax
	movw	ax,[sp+10]
	movw	hl,#0
	divwu
	nop
	pop	de
	addw	ax,de
	sknc
	incw	bc
	shrw	ax,1
	xchw	ax,bc			; AX: bits 16 and 17 of the sum
	cmpw	ax,#1
	movw	ax,bc
	bc	$2f
	bnz	$1f
	or	a,#0x80
	br	$2f
1:
	movw	ax,#0xffff
2:
	movw	de,ax
	ret

	; The next digit of q2 (Knuth, algorithm D). The remainder is the
	; three words at HL, s' is at [SP+12]. The digit goes where the top
	; word of the remainder was, and HL down a word.
.L_digit:
	movw	ax,[sp+14]
	movw	de,ax
	movw	ax,[hl+4]
	movw	bc,ax
	cmpw	ax,de
	movw	ax,#0xffff
	bz	$1f			; equal top digits: the division would give 65536
	movw	ax,[hl+2]
	push	hl
	movw	hl,#0
	divwu
	nop
	pop	hl
1:
	push	ax			; the digit; s' is at [SP+14] now
	movw	bc,ax
	movw	ax,[sp+14]
	mulhu
	movw	de,ax
	movw	ax,[hl]
	subw	ax,de
	movw	[hl],ax
	movw	ax,bc
	sknc
	incw	ax
	movw	de,ax
	movw	ax,[sp+0]
	movw	bc,ax
	movw	ax,[sp+16]
	mulhu
	addw	ax,de
	sknc
	incw	bc
	movw	de,ax
	movw	ax,[hl+2]
	subw	ax,de
	movw	[hl+2],ax
	movw	ax,bc
	sknc
	incw	ax
	movw	de,ax
	movw	ax,[hl+4]
	subw	ax,de			; 0, or below it for a digit that was too high
	bnc	$3f
	movw	[hl+4],ax
2:
	movw	ax,[sp+0]
	decw	ax
	movw	[sp+0],ax
	mov	a,[sp+14]
	add	a,[hl]
	mov	[hl],a
	mov	a,[sp+15]
	addc	a,[hl+1]
	mov	[hl+1],a
	mov	a,[sp+16]
	addc	a,[hl+2]
	mov	[hl+2],a
	mov	a,[sp+17]
	addc	a,[hl+3]
	mov	[hl+3],a
	movw	ax,[hl+4]
	sknc
	incw	ax
	movw	[hl+4],ax
	or	a,x
	bnz	$2b
3:
	pop	ax
	movw	[hl+4],ax
	decw	hl
	decw	hl
	ret

	.size	___rl78_sqrt64_asm, . - ___rl78_sqrt64_asm
#endif
