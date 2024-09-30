RUSTFLAGS="-Ctarget-feature=+simd128,+bulk-memory" cargo build --release --target wasm32-wasi
wasmtime compile target/wasm32-wasi/release/wasm-zlib-benchmark.wasm 
poop "wasmtime run --allow-precompiled wasm-zlib-benchmark.cwasm inflate miniz_oxide" "wasmtime run --allow-precompiled wasm-zlib-benchmark.cwasm inflate zlib-rs"
