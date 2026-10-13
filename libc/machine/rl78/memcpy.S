;---------------------------------------------------------------------
;
;	void __near * memcpy(void __near *s1, const void __near *s2,
;				   size_t n);
;
;	input:
;		s1 = AX
;		s2 = BC
;		n  = DE
;
;	output:
;		AX
;
;---------------------------------------------------------------------

; Byte by byte, for size; memcpy_speed.c is used otherwise.
#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__)) && defined(__OPTIMIZE_SIZE__)
    .file	"memcpy.S"
    .text
    .global  _memcpy
    .type	 _memcpy,@function
_memcpy:
  xchw ax, bc	; bc: s1
  addw ax, de
  xchw ax, de	; de: s2+n
  addw ax, bc
  movw hl, ax	; hl: s1+n
.L1:
  cmpw ax, bc	; 1
  sknz			; 2 -> 4
  ret			; 1

  decw de		; 1
  decw hl		; 1
  mov a, [de]	; 1 -> 4
  mov [hl], a	; 1
  movw ax, hl   ; 1
  br $.L1		; 2 -> 4
    .size _memcpy, . - _memcpy
#endif
