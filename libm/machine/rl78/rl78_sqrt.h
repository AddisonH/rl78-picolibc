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

/* Square roots for the RL78 by integer arithmetic.

   The root of the significand is built from the top down (Zimmermann's
   "Karatsuba square root"): a 16-bit root of the top 32 bits by Newton's
   iteration with the hardware divider, then each further piece by one
   division of the remainder by twice the root so far. The remainder is kept
   exact, so the result is correctly rounded (to nearest; a root is never
   halfway between two representable values).  */
#include <stdint.h>

/* floor(sqrt(h)) for h >= 2^30; *rem = h - root^2 (at most 2 * root).  */
static inline uint16_t rl78_isqrt32(uint32_t h, uint32_t *rem) {
  /* Chord through the end points, 4% low at worst; two Newton steps leave
     the estimate at most one too large.  */
  uint16_t t = (uint16_t)(h >> 16) - 0x4000;
  uint32_t g = 0x8000u + (t >> 1) + (t >> 3) + (t >> 5);
  g = (g + h / g) >> 1;
  g = (g + h / g) >> 1;
  if (g > 0xffff)
    g = 0xffff;
  uint32_t sq = g * g;
  while (sq > h) {
    g--;
    sq -= 2 * g + 1;
  }
  *rem = h - sq;
  return (uint16_t)g;
}
