;---------------------------------------------------------------------
;	_COM_strrchr_f
;
;	char __far * __far _COM_strrchr_f(const char __far *s, int c);
;
;	input:
;		s = A-DE
;		c = BC
;
;	output:
;		A-DE
;
;---------------------------------------------------------------------


	.text
	.global	__COM_strrchr_f
	.type	__COM_strrchr_f,@function

__COM_strrchr_f:
	MOV	ES,A		; HIGHW s(ret)
	CLRW	AX
	MOVW	HL,AX		; LOWW ret = 0, flag(X) = 0
.L1:
	MOV	A,ES:[DE]	; ch = *s
	CMP	A,C
	BNZ	$.L2		; if (*s != c) goto L2
	PUSH	DE
	POP	HL
	ONEB	X		; flag = 1
.L2:
	INCW	DE		; s++
	CMP0	A
	BNZ	$.L1		; if (ch != 0) goto L1
	PUSH	HL
	POP	DE		; LOWW ret
	CMP0	X
	SKZ
	MOV	A,ES		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strrchr
.type	_strrchr,@function
.set 	_strrchr, __COM_strrchr_f
#endif
