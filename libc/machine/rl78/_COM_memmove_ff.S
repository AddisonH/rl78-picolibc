;---------------------------------------------------------------------
;	_COM_memmove_ff
;
;	void __far * __far
;	_COM_memmove_ff(void __far *s1, const void __far *s2, size_t n);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;		n  = [SP+4]
;
;	output:
;		A-DE
;
;---------------------------------------------------------------------


	.text
	.global	__COM_memmove_ff
	.type	__COM_memmove_ff,@function

__COM_memmove_ff:
	PUSH	AX		; HIGHW s1(ret), HIGHW s2
	PUSH	DE		; LOWW ret
	CMP	A,X
	MOVW	AX,[SP+4+4]
	XCHW	AX,BC		; BC = n
	MOVW	HL,AX		; HL = LOWW s2
	BNZ	$.L1		; if (ES1 != ES2) goto L1
	MOVW	AX,HL
	CMPW	AX,DE
	BC	$.L2		; if (LOWW s1 > LOWW s2) goto L2
.L1:
	CLRW	AX
	CMPW	AX,BC
	BZ	$.L4		; if (n == 0) goto L4
	MOV	A,[SP+2]
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:[HL]
	MOV	X,A
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A
	INCW	HL
	INCW	DE		; *s1++ = *s2++
	DECW	BC		; n--
	BR	$.L1		; goto L1
.L2:
	ADDW	AX,BC
	MOVW	HL,AX		; s2 += n
	MOVW	AX,DE
	ADDW	AX,BC
	MOVW	DE,AX		; s1 += n
.L3:
	CLRW	AX
	CMPW	AX,BC
	BZ	$.L4		; if (n == 0) goto L4
	DECW	HL
	DECW	DE
	MOV	A,[SP+2]
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:[HL]
	MOV	X,A
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A	; *--s1 = *--s2
	DECW	BC		; n--
	BR	$.L3		; goto L3
.L4:
	POP	DE		; LOWW ret
	POP	AX		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_memmove
.type	_memmove,@function
.set 	_memmove, __COM_memmove_ff
#endif
