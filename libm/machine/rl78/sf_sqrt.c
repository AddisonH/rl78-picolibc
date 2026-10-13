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

/* sqrtf for the RL78: see rl78_sqrt.h.  */
#include "fdlibm.h"
#include "rl78_sqrt.h"

float
sqrtf(float x)
{
  union { float f; uint32_t u; } v = {x};
  uint32_t m = v.u & 0x007fffffUL;
  int16_t e = (int16_t)(v.u >> 23);

  if (e <= 0 || e >= 0xff) {
    if ((v.u << 1) == 0)
      return x; /* +-0 */
    if ((e & 0xff) == 0xff) {
      if (e != 0xff && !isnanf(x))
        return __math_invalidf(x); /* -Inf */
      return x + x; /* NaN, +Inf */
    }
    if (e != 0)
      return __math_invalidf(x); /* negative */
    /* Subnormal.  */
    e = 1;
    while (!(m & 0x00800000UL)) {
      m <<= 1;
      e--;
    }
  } else {
    m |= 0x00800000UL;
  }
  e -= 127;
  if (e & 1) {
    m <<= 1;
    e--;
  }

  /* The root c of m * 2^23, 2^23 <= c < 2^24: the 16-bit root of the top 32
     bits (m * 2^7), then 8 more bits.  */
  uint32_t r1;
  uint16_t s1 = rl78_isqrt32(m << 7, &r1);
  uint32_t num = r1 << 7;
  uint16_t q = (uint16_t)(num / s1);
  uint32_t w = num - (uint32_t)q * s1;
  uint32_t c = ((uint32_t)s1 << 8) + q;
  int32_t rem = (int32_t)(w << 9) - (int32_t)((uint32_t)q * q);
  while (rem < 0) {
    c--;
    rem += 2 * c + 1;
  }
  if ((uint32_t)rem > c)
    c++; /* may carry into the exponent */

  v.u = ((uint32_t)((e >> 1) + 126) << 23) + c;
  return v.f;
}

_MATH_ALIAS_f_f(sqrt)
