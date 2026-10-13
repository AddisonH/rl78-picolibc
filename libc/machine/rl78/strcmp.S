	.file	"strcmp.S"

#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__))
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
#endif
