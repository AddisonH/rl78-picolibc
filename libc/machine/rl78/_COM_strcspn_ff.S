;---------------------------------------------------------------------
;	_COM_strcspn_ff
;
;	size_t __far
;	_COM_strcspn_ff(const char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		AX
;---------------------------------------------------------------------

	.text
	.global	__COM_strcspn_ff
	.type	__COM_strcspn_ff,@function

	.extern	__COM_strpbrk_ff
	.extern	__COM_strlen_f

__COM_strcspn_ff:
	push	de		; save loww s1
	push	ax		; save highw s1
	call	!!__COM_strpbrk_ff
	cmp0	a
	bnz	$.L1
	clrw	ax
	cmpw	ax,de
	bnz	$.L1
	pop	ax		; restore highw s1
	pop	de		; restore loww s1
	br	!!__COM_strlen_f
.L1:
	pop	bc		; stack adjustment
	pop	bc		; restore loww s1
	movw	ax,de
	subw	ax,bc
	ret
