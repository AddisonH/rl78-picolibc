;---------------------------------------------------------------------
;	_COM_strcmp_ff
;
;	int __far _COM_strcmp_ff(const char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		AX
;---------------------------------------------------------------------


	.text
	.global	__COM_strcmp_ff
	.type	__COM_strcmp_ff,@function

__COM_strcmp_ff:
	XCHW	AX,BC		; B = HIGHW s1, C = HIGHW s2
	MOVW	HL,AX		; HL = LOWW s2
.L1:
	MOV	A,B
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[DE]	; ch = *s1
	MOV	X,A
	MOV	A,C
	MOV	ES,A		; HIGHW s2
	MOV	A,X
	SUB	A,ES:[HL]
	BNZ	$.L2		; if (ch != *s2) goto L2
	INCW	DE		; s1++
	INCW	HL		; s2++
	CMP0	X
	BNZ	$.L1		; if (ch != 0) goto L1
.L2:
	MOV	X,A
	SUBC	A,A
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strcmp
.type	_strcmp,@function
.set 	_strcmp, __COM_strcmp_ff
#endif
