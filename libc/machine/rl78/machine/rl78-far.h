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

#ifndef _MACHINE_RL78_FAR_H_
#define _MACHINE_RL78_FAR_H_

/*
 * Library functions for data that a near pointer does not reach.
 *
 * In the RL78's default data model pointers are 16 bits wide and address
 * F0000H-FFFFFH. Objects elsewhere (declared __far) take 32-bit pointers,
 * which the standard functions cannot be given. These variants can; the
 * suffix tells how many pointer parameters are far: _f one, _ff two. The
 * names are the ones Renesas compilers use.
 */

#include <stddef.h>
#include <stdint.h>
#include <sys/cdefs.h>

#define __FAR __far

_BEGIN_STD_C

/* <string.h> */
void __FAR * _COM_memchr_f(const void __FAR *s, int c, size_t n);
int _COM_memcmp_ff(const void __FAR *s1, const void __FAR *s2, size_t n);
void __FAR * _COM_memcpy_ff(void __FAR * __restrict s1, const void __FAR * __restrict s2, size_t n);
void __FAR * _COM_memmove_ff(void __FAR *s1, const void __FAR *s2, size_t n);
void __FAR * _COM_memset_f(void __FAR *s, int c, size_t n);
char __FAR * _COM_strcat_ff(char __FAR * __restrict s1, const char __FAR * __restrict s2);
char __FAR * _COM_strchr_f(const char __FAR *s, int c);
int _COM_strcmp_ff(const char __FAR *s1, const char __FAR *s2);
char __FAR * _COM_strcpy_ff(char __FAR * __restrict s1, const char __FAR * __restrict s2);
size_t _COM_strlen_f(const char __FAR *s);
char __FAR * _COM_strncat_ff(char __FAR * __restrict s1, const char __FAR * __restrict s2, size_t n);
int _COM_strncmp_ff(const char __FAR *s1, const char __FAR *s2, size_t n);
char __FAR * _COM_strncpy_ff(char __FAR * __restrict s1, const char __FAR * __restrict s2, size_t n);
size_t _COM_strcspn_ff(const char __FAR *s1, const char __FAR *s2);
char __FAR * _COM_strpbrk_ff(const char __FAR *s1, const char __FAR *s2);
char __FAR * _COM_strrchr_f(const char __FAR *s, int c);
size_t _COM_strspn_ff(const char __FAR *s1, const char __FAR *s2);
char __FAR * _COM_strstr_ff(const char __FAR *s1, const char __FAR *s2);

/* <stdlib.h> */
double _COM_atof_f(const char __FAR *nptr);
float _COM_atoff_f(const char __FAR *nptr);
int _COM_atoi_f(const char __FAR *nptr);
long int _COM_atol_f(const char __FAR *nptr);
long long int _COM_atoll_f(const char __FAR *nptr);
double _COM_strtod_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr);
float _COM_strtof_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr);
long double _COM_strtold_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr);
long int _COM_strtol_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr, int base);
long long int _COM_strtoll_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr, int base);
unsigned long int _COM_strtoul_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr, int base);
unsigned long long int _COM_strtoull_ff(const char __FAR * __restrict nptr, char __FAR * __FAR * __restrict endptr, int base);
void __FAR * _COM_bsearch_f(const void __FAR *key, const void __FAR *base, size_t nmemb, size_t size, int (*compar)(const void __FAR *, const void __FAR *));
void _COM_qsort_f(void __FAR *base, size_t nmemb, size_t size, int (*compar)(const void __FAR *, const void __FAR *));

/* <stdio.h> */
char __FAR * _COM_gets_f(char __FAR *s);
int _COM_puts_f(const char __FAR *s);
void _COM_perror_f(const char __FAR *s);

/* <inttypes.h> */
intmax_t _COM_strtoimax_ff(const char __far * __restrict nptr, char __far * __far * __restrict endptr, int base);
uintmax_t _COM_strtoumax_ff(const char __far * __restrict nptr, char __far * __far * __restrict endptr, int base);

_END_STD_C

#undef __FAR

#endif /* _MACHINE_RL78_FAR_H_ */
