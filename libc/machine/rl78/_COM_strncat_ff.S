;---------------------------------------------------------------------
;	_COM_strncat_ff
;
;	char __far * __far
;	_COM_strncat_ff(char __far *s1, const char __far *s2, size_t n);
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
	.global	__COM_strncat_ff
	.type	__COM_strncat_ff,@function

__COM_strncat_ff:
	PUSH	AX		; HIGHW s1(ret), HIGHW s2
	PUSH	DE		; LOWW ret
	MOV	ES,A
	MOVW	AX,[SP+4+4]
	MOVW	HL,AX		; n
.L1:
	MOV	A,ES:[DE]	; ch = *s1++
	INCW	DE
	CMP0	A
	BNZ	$.L1		; if (ch != 0) goto L1
	DECW	DE		; s1--
.L2:
	CLRW	AX
	CMPW	AX,HL
	BZ	$.L3		; if (n == 0) goto L3
	MOV	A,[SP+2]
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:0[BC]	; ch = *s2
	CMP0	A
	BZ	$.L3		; if (ch == 0) goto L3
	MOV	X,A
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A	; *s1++ = ch
	INCW	BC		; s2++
	INCW	DE
	DECW	HL		; n--
	BR	$.L2		; goto L2
.L3:
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	CLRB	A
	MOV	ES:[DE],A	; *s1 = 0
	POP	DE		; LOWW ret
	POP	AX		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strncat
.type	_strncat,@function
.set 	_strncat, __COM_strncat_ff
#endif
