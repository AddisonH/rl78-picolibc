    .file	"_COM_memcpy_ff.S"

	.text

	.global  __COM_memcpy_ff
	.type	 __COM_memcpy_ff,@function

;---------------------------------------------------------------------
;	_COM_memcpy_ff
;
;	void __far * __far _COM_memcpy_ff(void __far *s1, const void __far *s2,
;					  size_t n);
;
;	input:
;		s1 = ADE
;		s2 = XBC
;		n  = [SP+4]
;
;	output:
;		ADE
;
;---------------------------------------------------------------------

__COM_memcpy_ff:
#ifndef __FAR_DATA__
    push    ax
    movw    ax, [sp+4+2]
    movw    hl, ax
    push    de
1:
    clrw    ax
    cmpw    ax, hl
    bz      $2f
    mov     a, [sp+2]
    mov     es, a
    mov     a, es:0[bc]
    mov     x, a
    mov     a, [sp+3]
    mov     es, a
    mov     a, x
    mov     es:[de], a
    incw    bc
    incw    de
    decw    hl
    br      $1b
2:
    pop	de
    pop	ax
    ret
#else /* __FAR_DATA__ */
; NOTE: -mfar-data uses/needs this more general version of memcpy in the startup code
; to avoid the incorrect initialization of the global variables from a load range
; that can cross a segment boundary
	PUSH	DE
	XCHW	AX,BC		; B = HIGHW s1, C = HIGHW s2
	MOVW	HL,AX		; HL = LOWW s2
	MOVW	AX,[SP+6]	; make a copy of 'n' on the stack
	PUSH    AX		; FIXME: this is b/c libcxx\iterators\unwrap_iter.pass.cpp
.L1:				; passes SP+6 as s1 (when opt for speed)
	MOVW	AX,[SP]
	CMPW	AX,#0
	BZ	$.L2		; if (n == 0) goto L2
	DECW	AX		; n--
	MOVW	[SP],AX
	MOV	A,C
	MOV	ES,A		; HIGHW s2
	MOV	A,ES:[HL]	; ch = *s2
	MOV	X,A
	MOV	A,B
	MOV	ES,A		; HIGHW s1
	MOV	A,X
	MOV	ES:[DE],A	; *s1 = ch
	ONEW	AX		; s2++
	ADDW	AX,HL
	MOVW	HL,AX
	SKNC
	INC	C
	; NOTE: actually we're pretty sure that the destination buffer cannot cross a
	; segment boundary (as it should be in RAM) => just increment its offset
	INCW	DE
	BR	$.L1		; goto L1
.L2:
	POP	AX
	MOV	A,B		; return org s1 in A:DE
	POP	DE
	RET
#endif
.Lfunc_end1:
	.size	__COM_memcpy_ff, .Lfunc_end1-__COM_memcpy_ff

#if defined(__FAR_ROM__) || defined(__FAR_DATA__)
.weak	_memcpy
.type	_memcpy,@function
.set 	_memcpy, __COM_memcpy_ff
#endif
