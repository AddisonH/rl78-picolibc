;---------------------------------------------------------------------
;	_COM_strstr_ff
;
;	char __far * __far
;	_COM_strstr_ff(const char __far *s1, const char __far *s2);
;
;	input:
;		s1 = A-DE
;		s2 = X-BC
;	output:
;		A-DE
;---------------------------------------------------------------------


	.text
	.global	__COM_strstr_ff
	.type	__COM_strstr_ff,@function

__COM_strstr_ff:
	PUSH	AX		; HIGHW s1, HIGHW s2
	MOV	A,X
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:0[BC]
	CMP0	A
	BZ	$.L5		; if (*s2 == 0) return s1
.L1:
	MOVW	AX,DE		; LOWW s1(ret)
	MOVW	HL,AX
	MOV	A,[SP+1]
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[HL]
	CMP0	A
	BZ	$.L3		; if (*s1 == 0) return 0
	PUSH	BC		; save LOWW s2
.L2:
	MOV	A,[SP+2]
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:0[BC]
	CMP0	A
	BZ	$.L4		; if (*s2 == 0) goto L4
	MOV	X,A
	MOV	A,[SP+3]
	MOV	ES,A		; HIGHW s1
	MOV	A,ES:[HL]
	INCW	HL
	INCW	BC
	CMP	A,X
	BZ	$.L2		; if (*s1++ == *s2++) goto L2
	POP	BC		; restore LOWW s2
	INCW	DE		; ret++
	BR	$.L1		; goto L1
.L3:
	POP	AX		; stack adjustment
	CLRW	AX		; HIGHW ret = 0
	MOVW	DE,AX		; LOWW ret = 0
	RET
.L4:
	POP	AX		; stack adjustment
.L5:
	POP	AX
	RET

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_strstr
.type	_strstr,@function
.set 	_strstr, __COM_strstr_ff
#endif
