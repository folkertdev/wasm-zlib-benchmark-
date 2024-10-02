#!/bin/sh
set -eu

RUSTFLAGS="-Ctarget-feature=+simd128,+bulk-memory" cargo build --release --target wasm32-wasi

# Use sse4.2 only. Wasm doesn't have 256bit simd, so using only sse2 is the
# fairest option. This still has crc32 acceleration unlike wasm, but this
# benchmark shouldn't compute any crc32 anyway.
RUSTFLAGS="-Ctarget-feature=+sse4.2" cargo build --release
cp target/release/wasm-zlib-benchmark native-zlib-benchmark-sse42

# Also check against AVX2
RUSTFLAGS="-Ctarget-feature=+avx2" cargo build --release
cp target/release/wasm-zlib-benchmark native-zlib-benchmark-avx2

wasmtime compile target/wasm32-wasi/release/wasm-zlib-benchmark.wasm
poop "./native-zlib-benchmark-sse42 inflate zlib-rs" "./native-zlib-benchmark-avx2 inflate zlib-rs" "wasmtime run --allow-precompiled baseline-d693fe.cwasm inflate zlib-rs" "wasmtime run --allow-precompiled wasm-zlib-benchmark.cwasm inflate miniz_oxide" "wasmtime run --allow-precompiled wasm-zlib-benchmark.cwasm inflate zlib-rs"
