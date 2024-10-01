#!/bin/sh
set -eu

RUSTFLAGS="-Ctarget-feature=+simd128,+bulk-memory" cargo build --release --target wasm32-wasi
wasmtime compile target/wasm32-wasi/release/wasm-zlib-benchmark.wasm
perf record -k mono wasmtime --profile=jitdump --allow-precompiled wasm-zlib-benchmark.cwasm deflate zlib-rs
perf inject --jit --input perf.data --output perf.jit.data
perf report -M intel --input perf.jit.data
