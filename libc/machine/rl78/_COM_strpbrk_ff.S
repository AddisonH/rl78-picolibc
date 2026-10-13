;---------------------------------------------------------------------
;	_COM_strpbrk_ff
;
;	char __far * __far
;	_COM_strpbrk_ff(const char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		A-DE
;---------------------------------------------------------------------


	.text
	.global	__COM_strpbrk_ff
	.type	__COM_strpbrk_ff,@function

__COM_strpbrk_ff:
	PUSH	BC		; save LOWW s2
	MOVW	BC,AX		; B = HIGHW s1, C = HIGHW s2
	DECW	DE		; s1--
.L1:
	INCW	DE		; s1++
	MOV	A,B
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[DE]
	CMP0	A
	BZ	$.L3		; if (*s1 == 0) return 0
	MOV	X,A
	POP	HL		; restore LOWW s2
	PUSH	HL		; save LOWW s2
	MOV	A,C
	MOV	ES,A		; HIGHW s2
.L2:
	MOV	A,ES:[HL]
	CMP0	A
	BZ	$.L1		; if (*s2 == 0) goto L1
	INCW	HL		; s2++
	CMP	A,X
	BNZ	$.L2		; if (*s1 != *s2) goto L2
	POP	AX		; stack adjustment
	MOVW	AX,BC		; HIGHW ret
	RET
.L3:
	POP	AX		; stack adjustment
	CLRW	AX		; HIGHW ret = 0
	MOVW	DE,AX		; LOWW ret = 0
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strpbrk
.type	_strpbrk,@function
.set 	_strpbrk, __COM_strpbrk_ff
#endif
