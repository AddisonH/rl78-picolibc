;---------------------------------------------------------------------
;
;	void __near * memset(void __near *s, int c, size_t n);
;
;	input:
;		s = AX
;		c = BC
;		n = DE
;
;	output:
;		AX
;
;---------------------------------------------------------------------

; Byte by byte, for size; memset_speed.c is used otherwise.
#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__)) && defined(__OPTIMIZE_SIZE__)
	.file	"memset.S"
	.text
	.global  _memset
	.type	 _memset,@function
_memset:
  movw hl, ax
  addw ax, de
  movw de, ax
  movw ax, hl
  
.L1:
  cmpw ax, de   ; 1
  sknz			; 2
  ret			; 1 => 4

  decw de		; 1
  mov a, c		; 1
  mov [de], a	; 1
  movw ax, hl   ; 1 => 4
 
  br $.L1		; 2
	.size _memset, . - _memset
#endif
