;---------------------------------------------------------------------
;	_COM_memcmp_ff
;
;	int __far
;	_COM_memcmp_ff(const void __far *s1, const void __far *s2, size_t n);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;		n  = [SP+4]
;	output:
;		AX
;---------------------------------------------------------------------


	.text
	.global	__COM_memcmp_ff
	.type	__COM_memcmp_ff,@function

__COM_memcmp_ff:
	PUSH	AX		; HIGHW s1(ret), HIGHW s2
	MOVW	AX,BC
	MOVW	HL,AX		; HL = LOWW s2
	MOVW	AX,[SP+4+2]
	MOVW	BC,AX		; n
.L1:
	CLRW	AX
	CMPW	AX,BC
	BZ	$.L2		; if (n == 0) goto L2
	MOV	A,[SP+1]
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[DE]
	MOV	X,A
	MOV	A,[SP+0]
	MOV	ES,A		; HIGHW s2
	MOV	A,X
	SUB	A,ES:[HL]
	INCW	DE
	INCW	HL
	DECW	BC		; n--
	BZ	$.L1		; if (*s1++ == *s2++) goto L1
	MOV	X,A
	SUBC	A,A
.L2:
	POP	BC		; stack adjustment
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_memcmp
.type	_memcmp,@function
.set 	_memcmp, __COM_memcmp_ff
#endif
