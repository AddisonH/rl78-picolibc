;---------------------------------------------------------------------
;	_COM_memchr_f
;
;	void __far * __far _COM_memchr_f(const void __far *s, int c, size_t n);
;
;	input:
;		s = A-DE
;		c = BC
;		n = [SP+4]
;
;	output:
;		A-DE
;
;---------------------------------------------------------------------


	.text
	.global	__COM_memchr_f
	.type	__COM_memchr_f,@function

__COM_memchr_f:
	MOV	ES,A		; HIGHW s(ret)
	MOVW	AX,[SP+4]
	MOVW	HL,AX		; n
.L1:
	CLRW	AX
	CMPW	AX,HL
	BZ	$.L2		; if (n == 0) goto L2
	MOV	A,ES:[DE]
	CMP	A,C
	BZ	$.L3		; if (*s == c) goto L3
	INCW	DE		; s++
	DECW	HL		; n--
	BR	$.L1		; goto L1
.L2:
	MOVW	DE,AX		; ret = 0
	RET
.L3:
	MOV	A,ES		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_memchr
.type	_memchr,@function
.set 	_memchr, __COM_memchr_f
#endif
