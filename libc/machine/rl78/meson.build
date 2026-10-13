#
# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright © 2026 Addison Heavner
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#

srcs_machine = [
  'memchr.S',
  'memcmp.S',
  'memcpy.S',
  'memmove.S',
  'mempcpy.S',
  'memrchr.S',
  'memset.S',
  'setjmp.S',
  'stpcpy.S',
  'stpncpy.S',
  'strcat.S',
  'strchr.S',
  'strcmp.S',
  'strcpy.S',
  'strlen.S',
  'strncat.S',
  'strncmp.S',
  'strncpy.S',
  'strnlen.S',
  'strpbrk.S',
  'strrchr.S',
  'strspn.S',
  'strstr.S',
  'memcpy_speed.c',
  'sbrk.c',
  'memset_speed.c',
  '_COM_atof_f.c',
  '_COM_atoff_f.c',
  '_COM_atoi_f.c',
  '_COM_atol_f.c',
  '_COM_atoll_f.c',
  '_COM_bsearch_f.c',
  '_COM_gets_f.c',
  '_COM_memchr_f.S',
  '_COM_memcmp_ff.S',
  '_COM_memcpy_ff.S',
  '_COM_memmove_ff.S',
  '_COM_memset_f.S',
  '_COM_perror_f.c',
  '_COM_puts_f.c',
  '_COM_qsort_f.c',
  '_COM_strcat_ff.S',
  '_COM_strchr_f.S',
  '_COM_strcmp_ff.S',
  '_COM_strcpy_ff.S',
  '_COM_strcspn_ff.S',
  '_COM_strlen_f.S',
  '_COM_strncat_ff.S',
  '_COM_strncmp_ff.S',
  '_COM_strncpy_ff.S',
  '_COM_strpbrk_ff.S',
  '_COM_strrchr_f.S',
  '_COM_strspn_ff.S',
  '_COM_strstr_ff.S',
  '_COM_strtod_ff.c',
  '_COM_strtof_ff.c',
  '_COM_strtoimax_ff.S',
  '_COM_strtol_ff.c',
  '_COM_strtold_ff.S',
  '_COM_strtoll_ff.c',
  '_COM_strtoul_ff.c',
  '_COM_strtoull_ff.c',
  '_COM_strtoumax_ff.S',
]

subdir('machine')

# _COM_strtod_ff.c mixes float and double constants on purpose.
rl78_c_args = ['-Wno-double-promotion']

foreach params : targets
  target = params['name']
  target_dir = params['dir']
  target_c_args = params['c_args']
  set_variable('lib_machine' + target,
	       static_library('machine' + target,
			      srcs_machine,
			      pic: false,
			      include_directories: inc,
			      c_args: target_c_args + c_args + arg_fnobuiltin + rl78_c_args))
endforeach
