	.file	"mempcpy.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _mempcpy
	.type	 _mempcpy,@function

_mempcpy:

	xchw 	ax, de
	push	bc
	pop     hl
	cmpw	ax, #0
	bz	    $2f
	addw	ax, hl
	movw	bc, ax

1:	mov	    a, [hl]
	incw	hl
	mov	    [de], a
	incw	de
	movw	ax, bc
	cmpw	ax, hl
	bnz	    $1b
2:	movw	ax, de
	ret
	.size _mempcpy, . - _mempcpy
#endif
