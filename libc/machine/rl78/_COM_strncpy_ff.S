;---------------------------------------------------------------------
;	_COM_strncpy_ff
;
;	char __far * __far
;	_COM_strncpy_ff(char __far *s1, const char __far *s2, size_t n);
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
	.global	__COM_strncpy_ff
	.type	__COM_strncpy_ff,@function

__COM_strncpy_ff:
	PUSH	AX		; HIGHW s1(ret), HIGHW s2
	PUSH	DE		; LOWW ret
	MOVW	AX,[SP+4+4]
	MOVW	HL,AX		; n
.L1:
	CLRW	AX
	CMPW	AX,HL
	BZ	$.L2		; if (n == 0) goto L2
	MOV	A,[SP+2]
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:0[BC]
	MOV	X,A
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A
	INCW	DE		; *s1++ = *s2
	DECW	HL		; n--
	CMP0	A
	SKZ
	INCW	BC		; s2++
	BR	$.L1		; goto L1
.L2:
	POP	DE		; LOWW ret
	POP	AX		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strncpy
.type	_strncpy,@function
.set 	_strncpy, __COM_strncpy_ff
#endif
