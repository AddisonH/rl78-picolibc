	.file	"strcmp.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
#ifdef __OPTIMIZE_SIZE__
; Byte by byte, for size.
	.section .text

	.global  _strcmp
	.type	 _strcmp,@function

_strcmp:
    movw	de, ax
    movw	ax, bc
    movw	hl, ax
2:
	mov	    a, [de]
    mov	    x, a
    sub	    a, [hl]
    bnz	    $1f
    incw	de
    incw	hl
    cmp0	x
    bnz	    $2b
1:
	mov	    x, a
    subc	a, a
    ret

	.size _strcmp, . - _strcmp
#else
; For speed: two bytes to a load. A word access ignores bit 0 of the
; address, so words are read at even addresses only; the byte that shares
; a word with the last byte looked at may be read, never one beyond.
	.section .text
	.global  _strcmp
	.type	 _strcmp,@function
_strcmp:
	movw	de, ax
	movw	ax, bc
	movw	hl, ax
	mov	a, e
	xor	a, l
	bt	a.0, $3f	; one odd, one even: bytes
	mov	a, e
	bf	a.0, $2f
	mov	a, [de]		; both odd: one byte
	mov	x, a
	sub	a, [hl]
	bnz	$6f
	cmp0	x
	bz	$7f		; ax is 0
	incw	de
	incw	hl
2:
	movw	ax, [de]	; x: first byte, a: second
	cmpw	ax, [hl+0]
	bnz	$3f		; the bytes tell which way
	cmp0	x
	bz	$5f
	cmp0	a
	bz	$5f
	incw	de
	incw	de
	incw	hl
	incw	hl
	br	$2b
3:
	mov	a, [de]
	mov	x, a
	sub	a, [hl]
	bnz	$6f
	incw	de
	incw	hl
	cmp0	x
	bnz	$3b
6:
	mov	x, a
	subc	a, a
7:
	ret
5:
	clrw	ax
	ret
	.size _strcmp, . - _strcmp
#endif
#endif
