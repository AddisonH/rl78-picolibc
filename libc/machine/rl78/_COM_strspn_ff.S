;---------------------------------------------------------------------
;	_COM_strspn_ff
;
;	size_t __far _COM_strspn_ff(const char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		AX
;---------------------------------------------------------------------


	.text
	.global	__COM_strspn_ff
	.type	__COM_strspn_ff,@function

__COM_strspn_ff:
	PUSH	AX		; HIGHW s1, HIGHW s2
	MOVW	AX,BC
	MOVW	HL,AX		; LOWW s2
	CLRW	BC		; ret = 0
.L1:
	PUSH	HL		; save LOWW s2
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[DE]
	CMP0	A
	BZ	$.L3		; if (*s1 == 0) goto L3
	MOV	X,A
	INCW	DE		; s1++
	MOV	A,[SP+2]
	MOV	ES,A		; HIGHW s2
.L2:
	MOV	A,ES:[HL]
	CMP0	A
	BZ	$.L3		; if (*s2 == 0) goto L3
	INCW	HL		; s2++
	CMP	A,X
	BNZ	$.L2		; if (*s1 != *s2) goto L2
	POP	HL		; restore LOWW s2
	INCW	BC		; ret++
	BR	$.L1		; goto L1
.L3:
	ADDW	SP,#4
	MOVW	AX,BC		; ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strspn
.type	_strspn,@function
.set 	_strspn, __COM_strspn_ff
#endif
