	.file	"strlen.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
#ifdef __OPTIMIZE_SIZE__
; Byte by byte, for size.
	.section .text

	.global  _strlen
	.type	 _strlen,@function

_strlen:
   movw    de, ax
   movw    bc, ax
1:
   mov     a, [de]
   incw    de
   cmp0    a
   bnz     $1b
   decw    de
   movw    ax, de
   subw    ax, bc
   ret

	.size _strlen, . - _strlen
#else
; For speed: two bytes to a load. A word access ignores bit 0 of the
; address, so words are read at even addresses only; the byte that shares
; a word with the last byte looked at may be read, never one beyond.
	.section .text
	.global  _strlen
	.type	 _strlen,@function
_strlen:
	movw	de, ax
	movw	bc, ax		; bc: start
	mov	a, e
	bf	a.0, $2f
	mov	a, [de]		; odd start: one byte
	cmp0	a
	bz	$4f
	incw	de
2:
	movw	ax, [de]	; x: first byte, a: second
	incw	de		; not right before the load: a register
	incw	de		; written then costs a clock more
	cmp0	x
	bz	$3f
	cmp0	a
	bnz	$2b
	incw	de		; the second byte ends the string
3:
	decw	de
	decw	de
4:
	movw	ax, de
	subw	ax, bc
	ret
	.size _strlen, . - _strlen
#endif
#endif
