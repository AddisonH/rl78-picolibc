;---------------------------------------------------------------------
;	_COM_strcpy_ff
;
;	char __far * __far _COM_strcpy_ff(char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		A-DE
;---------------------------------------------------------------------


	.text
	.global	__COM_strcpy_ff
	.type	__COM_strcpy_ff,@function

__COM_strcpy_ff:
	MOVW	HL,AX		; H = HIGHW s1(ret), L = HIGHW s2
	PUSH	DE		; LOWW ret
.L1:
	MOV	A,L
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:0[BC]	; ch = *s2
	MOV	X,A
	MOV	A,H
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A	; *s1 = ch
	INCW	BC		; s2++
	INCW	DE		; s1++
	CMP0	A
	BNZ	$.L1		; if (ch != 0) goto L1
	POP	DE		; LOWW ret
	MOV	A,H		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strcpy
.type	_strcpy,@function
.set 	_strcpy, __COM_strcpy_ff
#endif
