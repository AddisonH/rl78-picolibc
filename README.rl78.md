# picolibc for the RL78

This fork adds Renesas RL78 support to [picolibc](https://github.com/picolibc/picolibc),
for use with the RL78 LLVM toolchain at <https://github.com/AddisonH/rl78-llvm>.
The work is on the `rl78` branch, on top of upstream `main`; everything else
is upstream history.

Status: early. The library, the start-up code and the test programs build,
and picolibc's test suite runs on [rl78sim](https://github.com/AddisonH/rl78sim).
The compiler driver does not select picolibc yet, and libc++ has not been
built against it.

## What the port consists of

| Path | Content |
|---|---|
| `libc/machine/rl78` | `setjmp`/`longjmp` for the LLVM ABI and the small assembly string and memory routines, from the newlib that Renesas publishes with "LLVM for Renesas RL78" (those files carry no licence notice of their own); word-wise `memcpy`/`memset` for builds that do not optimize for size |
| `picocrt/machine/rl78/crt0.c` | reset entry; copies `.data`, `.sdata` and `.dataf` from flash through far pointers, clears `.sbss` and `.bssf` |
| `picocrt/machine/rl78/vectors.S` | reset and interrupt vectors, option bytes (from libgloss) |
| `picocrt/machine/rl78/picolibc.ld.in` | linker script template: vector table, CALLT table, option bytes, `.rodata` in the mirror area, saddr and far sections |
| `libos/semihost/machine/rl78` | console output through UART0 (`SDR00`) and `_exit` by `HALT`, as RL78 simulators expect |
| `scripts/cross-clang-rl78.txt`, `scripts/run-rl78` | meson cross file and test runner |

Changes to shared files: `meson.build` takes `picocrt/machine/<cpu>/picolibc.ld.in`
when a machine has one and reads a `lib_c_args` cross property (options for
the library's objects alone); `picocrt/crt0.h` lets a machine do the `.data`
copy itself (`CRT0_DATA_INIT`).

## Building and testing

`clang`, `ld.lld`, `llvm-ar` (from rl78-llvm), `rl78sim` and `scripts/run-rl78`
on `PATH`:

```sh
meson setup build --cross-file scripts/cross-clang-rl78.txt \
    -Dmultilib=false -Dtests=true -Dtests-enable-posix-io=false \
    -Doptimization=s -Ddebug=false -Dspecsdir=none
ninja -C build -k 0
meson test -C build --no-rebuild
```

Known limits:

- `-Ddebug=false`: `ld.lld -r`, which combines the start-up objects, does
  not handle the RL78 relocation sequences of debug sections yet.
- 16 test programs do not build: their tables are larger than 64 KiB or than
  the mirror area. `meson test` has to be given the names of the others.
- The `*-no-flash` tests fail (the RL78 script has no RAM-only variant), and
  `test-stack-smash` fails.
- The simulator layer has no file system, hence `-Dtests-enable-posix-io=false`.
