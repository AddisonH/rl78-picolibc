	.file	"strcpy.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
#ifdef __OPTIMIZE_SIZE__
; Byte by byte, for size.
	.section .text

	.global  _strcpy
	.type	 _strcpy,@function

_strcpy:
   movw    de, ax
   movw    hl, ax
1:
   mov     a, 0[bc]
   mov     [de], a
   incw    bc
   incw    de
   cmp0    a
   bnz     $1b
   movw    ax, hl
   ret

	.size _strcpy, . - _strcpy
#else
; For speed: two bytes to a load. A word access ignores bit 0 of the
; address, so words are read at even addresses only; the byte that shares
; a word with the last byte looked at may be read, never one beyond.
	.section .text
	.global  _strcpy
	.type	 _strcpy,@function
_strcpy:
	push	ax		; the result
	movw	de, ax		; de: destination
	movw	ax, bc
	movw	hl, ax		; hl: source
	mov	a, e
	xor	a, l
	bt	a.0, $3f	; one odd, one even: bytes
	mov	a, l
	bf	a.0, $2f
	mov	a, [hl]		; both odd: one byte
	mov	[de], a
	incw	hl
	incw	de
	cmp0	a
	bz	$5f
2:
	movw	ax, [hl]	; x: first byte, a: second
	cmp0	x
	bz	$3f
	cmp0	a
	bz	$4f
	movw	[de], ax
	incw	hl
	incw	hl
	incw	de
	incw	de
	br	$2b
3:
	mov	a, [hl]
	mov	[de], a
	incw	hl
	incw	de
	cmp0	a
	bnz	$3b
	pop	ax
	ret
4:
	movw	[de], ax	; the word ends with the terminator
5:
	pop	ax
	ret
	.size _strcpy, . - _strcpy
#endif
#endif
