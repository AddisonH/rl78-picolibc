;---------------------------------------------------------------------
;	_COM_strlen_f
;
;	size_t __far _COM_strlen_f(const char __far *s);
;
;	input:
;		s = A-DE
;
;	output:
;		AX
;
;---------------------------------------------------------------------


	.text
	.global	__COM_strlen_f
	.type	__COM_strlen_f,@function

__COM_strlen_f:
	MOV	ES,A		; HIGHW s
	MOVW	AX,DE
	MOVW	BC,AX		; BC = s
.L1:
	MOV	A,ES:[DE]	; ch = *p++
	INCW	DE
	CMP0	A
	BNZ	$.L1		; if (ch != 0) goto L1
	DECW	DE		; p--
	MOVW	AX,DE
	SUBW	AX,BC		; ret = p - s
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strlen
.type	_strlen,@function
.set 	_strlen, __COM_strlen_f
#endif
