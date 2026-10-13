	.file	"memmove.S"

; Byte by byte, for size; memmove_speed.c is used otherwise.
#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__)) && defined(__OPTIMIZE_SIZE__)
	.section .text

	.global  _memmove
	.type	 _memmove,@function

_memmove:
  push    ax
  xchw    ax, de
  xchw    ax, bc
  movw    hl, ax
  cmpw    ax, de
  bc      $1f
5:
  clrw    ax
  cmpw    ax, bc
  bz      $4f
  mov     a, [hl]
  mov     [de], a
  incw    hl
  incw    de
  decw    bc
  br      $5b

1:
  addw    ax, bc
  movw    hl, ax
  movw    ax, de
  addw    ax, bc
  movw    de, ax
3:
  clrw    ax
  cmpw    ax, bc
  bz      $4f
  decw    hl
  decw    de
  mov     a, [hl]
  mov     [de], a
  decw    bc
  br      $3b
4:
  pop     ax
  ret

  .size _memmove, . - _memmove
#endif
