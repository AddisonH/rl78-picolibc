/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright © 2026 Addison Heavner
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials provided
 *    with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* .data is copied here: its image is in flash, out of reach of the near
 * pointers that the common code would use. */
#define CRT0_DATA_INIT

#include "../../crt0.h"

extern char             __stack[];

/* The same symbols as a far pointer sees them. */
extern const char __far rl78_data_source[] __asm__("___data_source");
extern const char __far rl78_sdata_source[] __asm__("___sdata_source");
extern const char __far rl78_dataf_source[] __asm__("___dataf_source");
extern char __far       rl78_dataf_start[] __asm__("___dataf_start");
extern char __far       rl78_bssf_start[] __asm__("___bssf_start");
extern char             __sdata_start[];
extern char             __sdata_end[];
extern char             __dataf_start[];
extern char             __dataf_end[];
extern char             __sbss_start[];
extern char             __sbss_end[];
extern char             __bssf_start[];
extern char             __bssf_end[];

/*
 * Sizes are differences of two addresses: a size symbol may be zero, and
 * the compiler takes the address of an object to be non-null.
 */
#define RL78_SIZE(sec) ((size_t)(__##sec##_end - __##sec##_start))

static __always_inline void
far_copy(char __far *dst, const char __far *src, size_t n)
{
    while (n--)
        *dst++ = *src++;
}

void __used
_cstart(void)
{
#ifndef NO_FLASH
    far_copy(__data_start, rl78_data_source, RL78_SIZE(data));
    far_copy(__sdata_start, rl78_sdata_source, RL78_SIZE(sdata));
    far_copy(rl78_dataf_start, rl78_dataf_source, RL78_SIZE(dataf));
#endif
    memset(__sbss_start, '\0', RL78_SIZE(sbss));
    for (size_t n = RL78_SIZE(bssf); n--;)
        rl78_bssf_start[n] = 0;
    __start();
}

/* Reset: set the stack pointer and continue in C. */
__asm__("	.section .text.init.enter,\"ax\",@progbits\n"
        "	.global	__start\n"
        "	.type	__start, @function\n"
        "__start:\n"
        "	movw	sp, #___stack\n"
        "	br	!!__cstart\n");
