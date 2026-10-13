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

/*
 * The linker symbols used here are the ones RL78 linker scripts have
 * always defined (__datastart, __romdatastart, __romdatacopysize, ...), so
 * that a script written for an earlier RL78 C library keeps working.
 * picolibc.ld defines them next to picolibc's own names.
 */

#include <stddef.h>
#include <stdint.h>

/* An address in data as a near pointer sees it. */
#define RL78_NEAR(name) extern char rl78_##name[] __asm__("__" #name)
/* The same for a far pointer: the image of initialized data is in flash. */
#define RL78_FAR(name)  extern char __far rl78_far_##name[] __asm__("__" #name)
/*
 * A size. It may be zero, and the compiler takes the address of an object
 * to be non-null unless the symbol is weak; weak also lets a script leave
 * out the sections it has no use for.
 */
#define RL78_SIZE(name) extern char rl78_##name[] __asm__("__" #name) __weak

RL78_NEAR(datastart);
RL78_FAR(romdatastart);
RL78_SIZE(romdatacopysize);
RL78_NEAR(sdatastart);
RL78_FAR(romsdatastart);
RL78_SIZE(romsdatacopysize);
RL78_FAR(datafstart);
RL78_FAR(romdatafstart);
RL78_SIZE(romdatafcopysize);
RL78_NEAR(sbssstart);
RL78_SIZE(sbsssize);
RL78_NEAR(bssstart);
RL78_SIZE(bsssize);
RL78_FAR(bssfstart);
RL78_SIZE(bssfsize);

#define rl78_size(name) ((size_t)(uintptr_t)rl78_##name)

/* The common code clears .bss and nothing else: .data is copied here, and
 * the init array is run here with the names above. */
#define CRT0_DATA_INIT
#define CONSTRUCTORS        0
#define POST_MEMORY_SETUP() rl78_init_array()
#define __bss_start         rl78_bssstart
#define __bss_size          rl78_bsssize

static void rl78_init_array(void);

#include "../../crt0.h"
#include <sys/_initfini.h>

static __always_inline void
far_copy(char __far *dst, const char __far *src, size_t n)
{
    while (n--)
        *dst++ = *src++;
}

static void
rl78_init_array(void)
{
#if defined(__INIT_FINI_ARRAY)
    void (**fn)(void);

    /* A script without .preinit_array leaves both symbols null. */
    for (fn = __preinit_array_start; fn != __preinit_array_end; fn++)
        (*fn)();
    for (fn = __init_array_start; fn != __init_array_end; fn++)
        (*fn)();
#endif
}

void __used
_cstart(void)
{
#ifndef NO_FLASH
    far_copy(rl78_datastart, rl78_far_romdatastart, rl78_size(romdatacopysize));
    far_copy(rl78_sdatastart, rl78_far_romsdatastart, rl78_size(romsdatacopysize));
    far_copy(rl78_far_datafstart, rl78_far_romdatafstart, rl78_size(romdatafcopysize));
#endif
    memset(rl78_sbssstart, '\0', rl78_size(sbsssize));
    for (size_t n = rl78_size(bssfsize); n--;)
        rl78_far_bssfstart[n] = 0;
    __start();
}

/* Reset: set the stack pointer and continue in C. */
__asm__("	.section .text.init.enter,\"ax\",@progbits\n"
        "	.global	__start\n"
        "	.type	__start, @function\n"
        "__start:\n"
        "	movw	sp, #__stack\n"
        "	br	!!__cstart\n");
