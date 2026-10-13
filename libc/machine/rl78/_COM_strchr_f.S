;---------------------------------------------------------------------
;	_COM_strchr_f
;
;	char __far * __far _COM_strchr_f(const char __far *s, int c);
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
	.global	__COM_strchr_f
	.type	__COM_strchr_f,@function

__COM_strchr_f:
	MOV	ES,A		; HIGHW s(ret)
.L1:
	MOV	A,ES:[DE]	; ch = *s
	CMP	A,C
	BZ	$.L2		; if (*s == c) goto L2
	INCW	DE		; s++
	CMP0	A
	BNZ	$.L1		; if (ch != 0) goto L1
	CLRW	AX		; ret = 0
	MOVW	DE,AX
	RET
.L2:
	MOV	A,ES		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strchr
.type	_strchr,@function
.set 	_strchr, __COM_strchr_f
#endif
