	.file	"memrchr.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
	.section .text

	.global  _memrchr
	.type	 _memrchr,@function

_memrchr:

	addw	ax, de
	movw	hl, ax
    movw    ax, de
1:	subw	ax, #1
	bc	    $2f
	xchw	ax, bc
	decw	hl
	cmps	x, [hl+0]
	xchw	ax, bc
	bnz	    $1b
	movw	ax, hl
	ret
2:	movw	ax, #0
	ret

	.size _memrchr, . - _memrchr
#endif
