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

#define _DEFAULT_SOURCE
#include <unistd.h>
#include <errno.h>
#include <stdint.h>
#include <stddef.h>

/*
 * The heap lies between the end of the data and the room kept for the
 * stack, by the symbols RL78 linker scripts define: __end, __stack and
 * __stack_size (256 bytes when the script does not say).
 */
extern char rl78_end[] __asm__("__end");
extern char rl78_stack[] __asm__("__stack");
extern char rl78_stack_size[] __asm__("__stack_size") __weak;

static char *rl78_brk = rl78_end;

void *
sbrk(ptrdiff_t incr)
{
    size_t reserve = (uintptr_t)rl78_stack_size;
    if (reserve == 0)
        reserve = 0x100;
    char *limit = rl78_stack - reserve;

    if (incr < 0) {
        if ((size_t)(rl78_brk - rl78_end) < (size_t)(-incr)) {
            errno = ENOMEM;
            return (void *)-1;
        }
    } else if (limit < rl78_brk || (size_t)(limit - rl78_brk) < (size_t)incr) {
        errno = ENOMEM;
        return (void *)-1;
    }
    void *ret = rl78_brk;
    rl78_brk += incr;
    return ret;
}
