/* Copyright (c) 2011 Red Hat Incorporated.
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met: 

     Redistributions of source code must retain the above copyright 
     notice, this list of conditions and the following disclaimer.

     Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

     The name of Red Hat Incorporated may not be used to endorse 
     or promote products derived from this software without specific 
     prior written permission.

   This software is provided by the copyright holders and contributors
   "AS IS" and any express or implied warranties, including, but not
   limited to, the implied warranties of merchantability and fitness for
   a particular purpose are disclaimed.  In no event shall Red Hat
   incorporated be liable for any direct, indirect, incidental, special,
   exemplary, or consequential damages (including, but not limited to,
   procurement of substitute goods or services; loss of use, data, or
   profits; or business interruption) however caused and on any theory of
   liability, whether in contract, strict liability, or tort (including
   negligence or otherwise) arising in any way out of the use of this
   software, even if advised of the possibility of such damage.  */


    .section ".vec","a"
    .short	__start

    .section ".ivec","a"
    .macro	_iv	x
    .weak	\x
    .short	\x
    .endm
#define IV(x) _iv ___vector_##x##_
#define IVx() .short 0

    /* To use a vector, simply define a global function named foo_handler()
       for any IV(foo) listed below (i.e. tm05_handler) */

    .global	_interrupt_vector_table
_interrupt_vector_table:
    IV(4)
    IV(6)
    IV(8)
    IV(a)
    IV(c)
    IV(e)
    IV(10)
    IV(12)

    IV(14)
    IV(16)
    IV(18)
    IV(1a)
    IV(1c)
    IV(1e)
    IV(20)
    IV(22)

    IV(24)
    IV(26)
    IV(28)
    IV(2a)
    IV(2c)
    IV(2e)
    IV(30)
    IV(32)

    IV(34)
    IV(36)
    IV(38)
    IV(3a)
    IV(3c)
    IV(3e)
    IV(40)
    IV(42)

    IV(44)
    IV(46)
    IV(48)
    IV(4a)
    IV(4c)
    IV(4e)
    IV(50)
    IV(52)

    IV(54)
    IV(56)
    IV(58)
    IV(5a)
    IV(5c)
    IV(5e)
    IV(60)
    IV(62)

    IV(64)
    IV(66)
    IV(68)
    IV(6a)
    IV(6c)
    IV(6e)
    IVx()
    IVx()

    IVx()
    IVx()
    IVx()
    IVx()
    IVx()
    IV(7e)
    /* Note: 126 vectors */


    .weak	__rl78_option_byte_0
    .weak	__rl78_option_byte_1
    .weak	__rl78_option_byte_2
    .weak	__rl78_option_byte_3
__rl78_option_byte_0 = 0x6e
__rl78_option_byte_1 = 0xff
__rl78_option_byte_2 = 0xe8
__rl78_option_byte_3 = 0x85

    .section ".option_byte", "a"
    .byte	__rl78_option_byte_0
    .byte	__rl78_option_byte_1
    .byte	__rl78_option_byte_2
    .byte	__rl78_option_byte_3

