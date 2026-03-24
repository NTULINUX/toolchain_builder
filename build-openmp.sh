#!/usr/bin/env bash
#
# Copyright (c) 2020 Martin Storsjo
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

rm -rf "build-openmp"
mkdir -p "build-openmp"
cd "build-openmp"
rm -rf CMake*

    cmake \
        -DCMAKE_GENERATOR=Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_AR="${PREFIX}/bin/llvm-ar" \
        -DCMAKE_RANLIB="${PREFIX}/bin/llvm-ranlib" \
        -DLLVM_ENABLE_RUNTIMES="openmp" \
        CMAKEFLAGS="-DLIBOMP_ASMFLAGS=-m64" \
        ..

cmake --build .
cmake --install .
cd ..
