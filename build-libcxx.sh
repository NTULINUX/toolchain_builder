#!/usr/bin/env bash
#
# Copyright (c) 2018 Martin Storsjo
# Copyright (c) 2026 Alec Ari
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

set -e

PREFIX="${1}"
if [ -z "${PREFIX}" ]; then
    echo "${0} dest"
    exit 1
fi

export PATH="${PREFIX}/bin:${PATH}"

cd "llvm-project/runtimes"

rm -rf "build"
mkdir -p "build"
cd "build"
rm -rf CMake*

    cmake \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_GENERATOR=Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_CXX_COMPILER_TARGET="x86_64-unknown-linux-gnu" \
        -DCMAKE_C_COMPILER_WORKS=TRUE \
        -DCMAKE_CXX_COMPILER_WORKS=TRUE \
        -DCMAKE_AR="${PREFIX}/bin/llvm-ar" \
        -DCMAKE_RANLIB="${PREFIX}/bin/llvm-ranlib" \
        -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
        -DLIBUNWIND_USE_COMPILER_RT=TRUE \
        -DLIBUNWIND_ENABLE_SHARED=OFF \
        -DLIBUNWIND_ENABLE_STATIC=ON \
        -DLIBCXX_USE_COMPILER_RT=ON \
        -DLIBCXX_ENABLE_SHARED=OFF \
        -DLIBCXX_ENABLE_STATIC=ON \
        -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=TRUE \
        -DLIBCXX_CXX_ABI=libcxxabi \
        -DLIBCXX_LIBDIR_SUFFIX="" \
        -DLIBCXX_INCLUDE_TESTS=FALSE \
        -DLIBCXX_INSTALL_MODULES=ON \
        -DLIBCXX_INSTALL_MODULES_DIR="${PREFIX}/share/libc++/v1" \
        -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=FALSE \
        -DLIBCXXABI_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
        -DLIBCXXABI_ENABLE_SHARED=OFF \
        -DLIBCXXABI_LIBDIR_SUFFIX="" \
        ..

cmake --build .
cmake --install .
cd ..
