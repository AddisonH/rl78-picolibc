;---------------------------------------------------------------------
;	_COM_strcat_ff
;
;	char __far * __far _COM_strcat_ff(char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		A-DE
;---------------------------------------------------------------------


	.text
	.global	__COM_strcat_ff
	.type	__COM_strcat_ff,@function

__COM_strcat_ff:
	MOVW	HL,AX		; H = HIGHW s1(ret), L = HIGHW s2
	PUSH	DE		; LOWW ret
	MOV	ES,A
.L1:
	MOV	A,ES:[DE]	; ch = *s1++
	INCW	DE
	CMP0	A
	BNZ	$.L1		; if (ch != 0) goto L1
	DECW	DE		; s1--
.L2:
	MOV	A,L
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:0[BC]	; ch = *s2
	MOV	X,A
	MOV	A,H
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A	; *s1 = ch
	INCW	BC		; s2++
	INCW	DE		; s1++
	CMP0	A
	BNZ	$.L2		; if (ch != 0) goto L2
	POP	DE		; LOWW ret
	MOV	A,H		; HIGHW ret
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strcat
.type	_strcat,@function
.set 	_strcat, __COM_strcat_ff
#endif
