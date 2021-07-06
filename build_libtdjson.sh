#!/bin/bash -e

__DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

build_openssl_ios() {
	local src_d=OpenSSL-Universal
	local output_d=./openssl/ios
	local output_f_crypto="$output_d/lib/libcrypto.a"
	local output_f_ssl="$output_d/lib/libssl.a"
	mkdir -p "$output_d/lib"
	lipo -extract x86_64 "$src_d/iphonesimulator/lib/libcrypto.a" -output "$output_f_crypto"
	lipo "$src_d/iphoneos/lib/libcrypto.a" "$output_f_crypto" -create -output "$output_f_crypto"
	lipo -extract x86_64 "$src_d/iphonesimulator/lib/libssl.a" -output "$output_f_ssl"
	lipo "$src_d/iphoneos/lib/libssl.a" "$output_f_ssl" -create -output "$output_f_ssl"

	mkdir -p "$output_d/include"
	cp -r "$src_d/iphoneos/include/openssl" "$output_d/include/"
}
build_openssl_macos() {
	local src_d=OpenSSL-Universal
	local output_d=./openssl/macos
	local output_f_crypto="$output_d/lib/libcrypto.a"
	local output_f_ssl="$output_d/lib/libssl.a"
	mkdir -p "$output_d/lib"
	cp "$src_d/macosx/lib/libcrypto.a" "$output_f_crypto"
	cp "$src_d/macosx/lib/libssl.a" "$output_f_ssl"

	mkdir -p "$output_d/include"
	cp -r "$src_d/macosx/include/openssl" "$output_d/include"
}

cd "$__DIR__"

rm -fr openssl
build_openssl_ios
build_openssl_macos

cd td

rm -fr build
# jna example: https://github.com/MityaSaray/clojure-tdlib-json/blob/master/src/java/tdlib_json/TdJsonLib.java
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target prepare_cross_compiling

cd ..
php SplitSource.php

cd build
cmake --build . --target tdjson
cmake --build . --target tdjson_static

cd ..
php SplitSource.php --undo

cd ..
