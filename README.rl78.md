# picolibc for the RL78

This fork adds Renesas RL78 support to [picolibc](https://github.com/picolibc/picolibc),
for use with the RL78 LLVM toolchain at <https://github.com/AddisonH/rl78-llvm>.
The work is on the `rl78` branch, on top of upstream `main`; everything else
is upstream history.

Status: the library builds for every variant the compiler looks for
(`clang -print-multi-lib`), the compiler driver selects it when the sysroot
contains `picolibc.ld`, libc++ builds against it, and picolibc's test suite
passes on [rl78sim](https://github.com/AddisonH/rl78sim).

## What the port consists of

| Path | Content |
|---|---|
| `libc/machine/rl78` | `setjmp`/`longjmp` for the LLVM ABI and the small assembly string and memory routines of the newlib that Renesas publishes with "LLVM for Renesas RL78" (those files carry no licence notice of their own); for builds that do not optimize for size, word-wise `memcpy`, `memset`, `memmove`, `memcmp`, `strlen`, `strcpy`, `strcmp` and `memchr`; `sbrk`; the far-pointer functions (`_COM_*_f`, declared in `<machine/rl78-far.h>`) |
| `libm/machine/rl78` | `sqrt` and `sqrtf` by integer arithmetic |
| `picocrt/machine/rl78/crt0.c` | reset entry; copies `.data`, `.sdata` and `.dataf` from flash through far pointers, clears `.sbss` and `.bssf`, runs the init array |
| `picocrt/machine/rl78/vectors.S` | reset and interrupt vectors, option bytes (from libgloss) |
| `picocrt/machine/rl78/picolibc.ld.in` | linker script template: vector table, CALLT table, option bytes, `.rodata` in the mirror area, saddr and far sections |
| `libos/semihost/machine/rl78` | console output through UART0 (`SDR00`) and `_exit` by `HALT`, as RL78 simulators expect |
| `scripts/cross-clang-rl78.txt`, `scripts/run-rl78` | meson cross file and test runner |

The start-up code, `sbrk` and the init and fini arrays use the linker symbols
that RL78 linker scripts have always defined (`__datastart`,
`__romdatacopysize`, `__bsssize`, `__init_array_start`, `__end`, `__stack`,
...), so a script written for newlib and libgloss works unchanged;
`picolibc.ld` defines them next to picolibc's own names.

Changes to shared files: `meson.build` takes `picocrt/machine/<cpu>/picolibc.ld.in`
when a machine has one and reads a `lib_c_args` cross property (options for
the library's objects alone); `picocrt/crt0.h` lets a machine do the `.data`
copy itself (`CRT0_DATA_INIT`).

## Building and testing

`clang`, `ld.lld`, `llvm-ar` (from rl78-llvm), `rl78sim` and `scripts/run-rl78`
on `PATH`. All variants, as a toolchain needs them:

```sh
meson setup build --cross-file scripts/cross-clang-rl78.txt \
    -Dmultilib=true -Dtests=false -Doptimization=s -Dspecsdir=none \
    -Dprefix=$PWD/install
ninja -C build install
```

`install/lib/<variant>/` then goes to
`lib/clang-runtimes/rl78-unknown-elf/<variant>/lib/` of the toolchain,
together with `install/lib/picolibc.ld` and `picolibcpp.ld`, and
`install/include/` to `.../<variant>/include/`.

One variant with the test suite:

```sh
meson setup build-test --cross-file scripts/cross-clang-rl78.txt \
    -Dmultilib=false -Dtests=true -Dtests-enable-posix-io=false \
    -Doptimization=s -Dspecsdir=none
ninja -C build-test -k 0
meson test -C build-test --no-rebuild <the tests that were built>
```

Notes:

- 15 test programs do not build: their tables are larger than 64 KiB or than
  the mirror area. `meson test` has to be given the names of the others
  (`meson introspect --tests`).
- The simulator layer has no file system, hence
  `-Dtests-enable-posix-io=false`.
- Printf comes in picolibc's usual levels; an application picks a smaller
  one at link time, e.g. `-Wl,--defsym=_vfprintf=___i_vfprintf` for the
  integer-only version (note the RL78's leading underscore).
