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

/* sqrt for the RL78: see rl78_sqrt.h.  */
#include "fdlibm.h"
#include "rl78_sqrt.h"

#ifdef _NEED_FLOAT64

#ifdef __RL78_S3__
/* sqrt_s3.S takes the positive normal numbers and comes here with the
   rest.  */
#define RL78_SQRT64 __rl78_sqrt64_c
__float64 __rl78_sqrt64_c(__float64 x);

__attribute__((naked)) __float64
sqrt64(__float64 x __attribute__((unused)))
{
  __asm__("br !!___rl78_sqrt64_asm");
}
#else
#define RL78_SQRT64 sqrt64
#endif

__float64
RL78_SQRT64(__float64 x)
{
  union { __float64 d; uint64_t u; } v = {x};
  uint64_t m = v.u & 0x000fffffffffffffULL;
  int16_t e = (int16_t)(v.u >> 52);

  if (e <= 0 || e >= 0x7ff) {
    if ((v.u << 1) == 0)
      return x; /* +-0 */
    if ((e & 0x7ff) == 0x7ff) {
      if (e != 0x7ff && !isnan(x))
        return __math_invalid(x); /* -Inf */
      return x + x; /* NaN, +Inf */
    }
    if (e != 0)
      return __math_invalid(x); /* negative */
    /* Subnormal.  */
    e = 1;
    while (!(m & 0x0010000000000000ULL)) {
      m <<= 1;
      e--;
    }
  } else {
    m |= 0x0010000000000000ULL;
  }
  e -= 1023;
  if (e & 1) {
    m <<= 1;
    e--;
  }

  /* The root c of m * 2^52, 2^52 <= c < 2^53. First the 32-bit root s of
     n = m * 2^10 and its remainder r.  */
  uint64_t n = m << 10;
  uint32_t lo = (uint32_t)n, r1;
  uint16_t s1 = rl78_isqrt32((uint32_t)(n >> 32), &r1);
  uint16_t a1 = (uint16_t)(lo >> 16);
  uint32_t num = (r1 << 15) | (a1 >> 1);
  uint32_t q = num / s1;
  uint32_t u = ((num - q * s1) << 1) | (a1 & 1);
  uint64_t s = ((uint64_t)s1 << 16) + q;
  int64_t r = (int64_t)(((uint64_t)u << 16) | (uint16_t)lo) - (int64_t)((uint64_t)q * q);
  if (r < 0) {
    s--;
    r += 2 * s + 1;
  }

  /* 21 more bits: the low limb of m * 2^52 = n * 2^42 is zero, so the next
     piece is q2 = r * 2^20 / s with remainder w. r <= 2s; after taking whole
     multiples of s out, two 10-bit digits by a 16-bit divisor that is never
     too small, so each digit comes out at most 2 low.  */
  uint32_t s32 = (uint32_t)s, q2 = 0;
  while ((uint64_t)r >= s32) {
    r -= s32;
    q2++;
  }
  uint32_t w = (uint32_t)r;
  uint16_t sh = (uint16_t)(s32 >> 16), sl = (uint16_t)s32;
  for (int8_t i = 0; i < 2; i++) {
    uint32_t t = w >> 6;
    uint16_t d = (uint16_t)(t / ((uint32_t)sh + 1));
    /* w * 2^10 - d * s, below 3s.  */
    uint64_t nw = ((uint64_t)(t - (uint32_t)d * sh) << 16) +
                  ((uint32_t)((uint16_t)w & 63) << 10) - (uint32_t)d * sl;
    while (nw >= s32) {
      nw -= s32;
      d++;
    }
    w = (uint32_t)nw;
    q2 = (q2 << 10) + d;
  }
  uint64_t c = ((uint64_t)s32 << 21) + q2;
  int64_t rem = (int64_t)((uint64_t)w << 22) - (int64_t)((uint64_t)q2 * q2);
  while (rem < 0) {
    c--;
    rem += 2 * c + 1;
  }
  if ((uint64_t)rem > c)
    c++; /* may carry into the exponent */

  v.u = ((uint64_t)((e >> 1) + 1022) << 52) + c;
  return v.d;
}

_MATH_ALIAS_d_d(sqrt)

#endif /* _NEED_FLOAT64 */
