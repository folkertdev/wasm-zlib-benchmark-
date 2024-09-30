RUSTFLAGS="-Ctarget-feature=+simd128" cargo build --release --target wasm32-wasi
perf record -k mono wasmtime --profile=jitdump target/wasm32-wasi/release/wasm-zlib-benchmark.wasm inflate zlib-rs
perf inject --jit --input perf.data --output perf.jit.data
perf report -M intel --input perf.jit.data
