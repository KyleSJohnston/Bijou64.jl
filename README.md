# Bijou64.jl

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://kylesjohnston.github.io/Bijou64.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://kylesjohnston.github.io/Bijou64.jl/dev)
[![Build Status](https://github.com/kylesjohnston/Bijou64.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kylesjohnston/Bijou64.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![JET](https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a)](https://github.com/aviatesk/JET.jl)

A Julia implementation of the bijou64 variable-length integer encoding

See the [specification](https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md).

## Performance

See https://github.com/inkandswitch/bijou/blob/main/bijou64/SHOOTOUT_ANALYSIS_X86.md for details.
All figures are in microseconds.
Rust values come from the Rust repo.
Julia values are medians from `./benchmarks` on my computer.

The last update to LittleEndianBase128.jl was in August 2018, so there are likely available optimizations to the code in that package.

### Encoding

| Distribution | Rust | LittleEndianBase128.jl | Bijou.jl |
| :-- | --: | --: | --: |
| tiny | 1.92 | 15.53 | 7.02 |
| small | 10.37 | 16.92 | 20.20 |
| medium | 11.02| 20.98 | 29.34 |
| large | 18.95 | 44.87 | 54.96 |
| boundary | 10.64 | 35.20 | 47.47 |
| uniform | 11.93 | 44.62 | 54.87 |

### Decoding

| Distribution | Rust | LittleEndianBase128.jl | Bijou.jl |
| :-- | --: | --: | --: |
| tiny | 1.78 | 1222 | 7.40 |
| small | 3.93 | 2371 | 130.18 |
| medium | 3.86 | 4442 | 200.71 |
| large | 3.11 | 8386 | 397.74 |
| boundary | 3.75 | 4301 | 238.83 |
| uniform | 3.08 | 8398 | 398.72 |
