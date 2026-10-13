	.file	"memcmp.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
#ifdef __OPTIMIZE_SIZE__
; Byte by byte, for size.
	.section .text

	.global  _memcmp
	.type	 _memcmp,@function

_memcmp:
   xchw    ax, de
   xchw    ax, bc
   movw    hl, ax
2:
   clrw    ax
   cmpw    ax, bc
   bz      $1f
   mov     a, [de]
   sub     a, [hl]
   incw    de
   incw    hl
   decw    bc
   bz      $2b
   mov     x, a
   subc    a, a
1:
   ret

	.size _memcmp, . - _memcmp
#else
; For speed: two bytes to a load. A word access ignores bit 0 of the
; address, so words are read at even addresses only; the byte that shares
; a word with the last byte looked at may be read, never one beyond.
	.section .text
	.global  _memcmp
	.type	 _memcmp,@function
_memcmp:
	xchw	ax, de
	xchw	ax, bc
	movw	hl, ax		; de: s1, hl: s2, bc: n
	mov	a, e
	xor	a, l
	bt	a.0, $3f	; one odd, one even: bytes
	mov	a, e
	bf	a.0, $2f
	clrw	ax		; both odd: one byte
	cmpw	ax, bc
	bz	$7f
	mov	a, [de]
	sub	a, [hl]
	bnz	$6f
	incw	de
	incw	hl
	decw	bc
2:
	movw	ax, bc
	cmpw	ax, #2
	bc	$3f
	movw	ax, [de]
	cmpw	ax, [hl+0]
	bnz	$3f		; the bytes tell which way
	incw	de
	incw	de
	incw	hl
	incw	hl
	decw	bc
	decw	bc
	br	$2b
3:
	clrw	ax
	cmpw	ax, bc
	bz	$7f
	mov	a, [de]
	sub	a, [hl]
	incw	de
	incw	hl
	decw	bc
	bz	$3b
6:
	mov	x, a
	subc	a, a
7:
	ret
	.size _memcmp, . - _memcmp
#endif
#endif
