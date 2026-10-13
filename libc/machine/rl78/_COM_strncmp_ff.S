;---------------------------------------------------------------------
;	_COM_strncmp_ff
;
;	int __far
;	_COM_strncmp_ff(const char __far *s1, const char __far *s2, size_t n);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;		n  = [SP+4]
;	output:
;		AX
;---------------------------------------------------------------------


	.text
	.global	__COM_strncmp_ff
	.type	__COM_strncmp_ff,@function

__COM_strncmp_ff:
	PUSH	AX		; HIGHW s1, HIGHW s2
	MOVW	AX,BC
	MOVW	HL,AX		; HL = LOWW s2
	MOVW	AX,[SP+4+2]
	MOVW	BC,AX		; n
.L1:
	CLRW	AX
	CMPW	AX,BC
	BZ	$.L3		; if (n == 0) goto L3
	MOV	A,[SP+1]
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[DE]
	MOV	X,A		; c1 = *s1
	MOV	A,[SP+0]
	MOV	ES,A		; HIGHW s2
	MOV	A,X
	SUB	A,ES:[HL]
	BNZ	$.L2		; if (*s1 != *s2) goto L2
	INCW	DE		; s1++
	INCW	HL		; s2++
	DECW	BC		; n--
	CMP0	X
	BNZ	$.L1		; if (c1 != 0) goto L1
.L2:
	MOV	X,A
	SUBC	A,A
.L3:
	POP	BC		; stack adjustment
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strncmp
.type	_strncmp,@function
.set 	_strncmp, __COM_strncmp_ff
#endif
