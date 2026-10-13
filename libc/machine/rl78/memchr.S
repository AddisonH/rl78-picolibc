	.file	"memchr.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
#ifdef __OPTIMIZE_SIZE__
; Byte by byte, for size.
	.section .text

	.global  _memchr
	.type	 _memchr,@function

_memchr:

   movw    hl, ax
3:
   clrw    ax
   cmpw    ax, de
   bz      $1f
   mov     a, c
   cmp     a, [hl]
   bz      $2f
   incw    hl
   decw    de
   br      $3b
2:
   movw    ax, hl
1:
   ret

	.size _memchr, . - _memchr
#else
; For speed: two bytes to a load. A word access ignores bit 0 of the
; address, so words are read at even addresses only; the byte that shares
; a word with the last byte looked at may be read, never one beyond.
	.section .text
	.global  _memchr
	.type	 _memchr,@function
_memchr:
	movw	hl, ax		; hl: s, c: the byte, de: n
	mov	a, l
	bf	a.0, $2f
	movw	ax, de		; odd start: one byte
	cmpw	ax, #0
	bz	$8f
	mov	a, [hl]
	cmp	a, c
	bz	$6f
	incw	hl
	decw	de
2:
	movw	ax, de
	cmpw	ax, #2
	bc	$4f
	movw	ax, [hl]	; x: first byte, a: second
	xch	a, x
	cmp	a, c
	bz	$6f
	mov	a, x
	cmp	a, c
	bz	$5f
	incw	hl
	incw	hl
	decw	de
	decw	de
	br	$2b
4:
	cmp0	x		; ax is n: one byte left, or none
	bz	$8f
	mov	a, [hl]
	cmp	a, c
	bz	$6f
8:
	clrw	ax
	ret
5:
	incw	hl
6:
	movw	ax, hl
	ret
	.size _memchr, . - _memchr
#endif
#endif
