/*
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2026 Addison Heavner
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* memmove for the RL78: words, eight bytes to a turn of the loop, from the
   end that does not run into the source. A word access ignores bit 0 of
   the address, so words move only between even addresses: bytes all the
   way when just one of the pointers is odd.  */
/* When optimizing for size memmove.S provides the function instead.  */
#if !(defined(__FAR_ROM__) || defined(__FAR_DATA__)) && !defined(__OPTIMIZE_SIZE__)

#include <stddef.h>
#include <stdint.h>

typedef uint16_t __attribute__((__may_alias__)) word;

void *memmove(void *dst, const void *src, size_t n) {
  unsigned char *d = dst;
  const unsigned char *s = src;
  int bytes = (((uintptr_t)d ^ (uintptr_t)s) & 1) != 0;

  if ((uintptr_t)d - (uintptr_t)s >= n) {
    /* The destination starts below the source or beyond its end: upwards. */
    if (bytes) {
      for (; n; --n)
        *d++ = *s++;
      return dst;
    }
    if (((uintptr_t)d & 1) && n) {
      *d++ = *s++;
      --n;
    }
    for (size_t blocks = n >> 3; blocks; --blocks) {
      ((word *)d)[0] = ((const word *)s)[0];
      ((word *)d)[1] = ((const word *)s)[1];
      ((word *)d)[2] = ((const word *)s)[2];
      ((word *)d)[3] = ((const word *)s)[3];
      d += 8;
      s += 8;
    }
    if (n & 4) {
      ((word *)d)[0] = ((const word *)s)[0];
      ((word *)d)[1] = ((const word *)s)[1];
      d += 4;
      s += 4;
    }
    if (n & 2) {
      *(word *)d = *(const word *)s;
      d += 2;
      s += 2;
    }
    if (n & 1)
      *d = *s;
    return dst;
  }

  /* Downwards from the end.  */
  d += n;
  s += n;
  if (bytes) {
    for (; n; --n)
      *--d = *--s;
    return dst;
  }
  if (((uintptr_t)d & 1) && n) {
    *--d = *--s;
    --n;
  }
  for (size_t blocks = n >> 3; blocks; --blocks) {
    d -= 8;
    s -= 8;
    ((word *)d)[3] = ((const word *)s)[3];
    ((word *)d)[2] = ((const word *)s)[2];
    ((word *)d)[1] = ((const word *)s)[1];
    ((word *)d)[0] = ((const word *)s)[0];
  }
  if (n & 4) {
    d -= 4;
    s -= 4;
    ((word *)d)[1] = ((const word *)s)[1];
    ((word *)d)[0] = ((const word *)s)[0];
  }
  if (n & 2) {
    d -= 2;
    s -= 2;
    *(word *)d = *(const word *)s;
  }
  if (n & 1)
    *--d = *--s;
  return dst;
}

#endif
