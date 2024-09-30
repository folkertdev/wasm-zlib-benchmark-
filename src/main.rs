use zlib_rs::{deflate::DeflateConfig, inflate::InflateConfig};

fn main() {
    let mut it = std::env::args();

    let _ = it.next().unwrap();

    let silesia_small_tar = include_bytes!("/home/folkertdev/rust/zlib-rs/silesia-small.tar");
    let silesia_small_tar_gz = include_bytes!("/home/folkertdev/rust/zlib-rs/silesia-small.tar.gz");

    match it.next().unwrap().as_str() {
        "inflate" => match it.next().unwrap().as_str() {
            "miniz_oxide" => {
                for _ in 0..10 {
                    let mut buf = vec![0; 1 << 24];
                    let n = miniz_oxide::inflate::decompress_slice_iter_to_slice(
                        &mut buf,
                        std::iter::once(silesia_small_tar_gz.as_slice()),
                        true,
                        false,
                    )
                    .expect("Failed to decompress!");

                    assert_eq!(n, 15736320);
                }
            }
            "zlib-rs" => {
                for _ in 0..10 {
                    let mut buf = vec![0; 1 << 24];
                    let (out, err) = zlib_rs::inflate::uncompress_slice(
                        &mut buf,
                        silesia_small_tar_gz.as_slice(),
                        InflateConfig::default(),
                    );
                    assert_eq!(err as i32, 0);
                    assert_eq!(out.len(), 15736320);
                }
            }
            other => unreachable!("other: {other}"),
        },
        "deflate" => match it.next().unwrap().as_str() {
            "miniz_oxide" => {
                let vec =
                    miniz_oxide::deflate::compress_to_vec_zlib(silesia_small_tar.as_slice(), 6);

                // assert_eq!(vec.len(), 6411455);
            }
            "zlib-rs" => {
                let mut buf = vec![0; 1 << 24];
                let (out, err) = zlib_rs::deflate::compress_slice(
                    &mut buf,
                    silesia_small_tar.as_slice(),
                    DeflateConfig::new(9),
                );
                assert_eq!(err as i32, 0);
                // assert_eq!(out.len(), 6457753);
            }
            other => unreachable!("other: {other}"),
        },
        other => unreachable!("other: {other}"),
    }
}
