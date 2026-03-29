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

LLVM_BRANCH="release/22.x"

PREFIX="${1}"
if [ -z "${PREFIX}" ]; then
    echo "${0} dest"
    exit 1
fi

if [ ! -d llvm-project ]; then
    git clone --depth=1 --single-branch -b "${LLVM_BRANCH}" https://github.com/llvm/llvm-project.git
else
    cd llvm-project
    git pull
    cd ..
fi

# Comment the line below to drastically speed up build
#LTO=("-DLLVM_ENABLE_LTO=thin" "-DLLVM_PARALLEL_LINK_JOBS=8")

cd "llvm-project/llvm"

PROJECTS="clang;lld;polly"

rm -rf "build"
mkdir -p "build"
cd "build"
rm -rf CMake*

cmake \
    -DCMAKE_C_FLAGS="-O3 -march=x86-64-v3" \
    -DCMAKE_CXX_FLAGS="-O3 -march=x86-64-v3" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-llvm-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-llvm-linux-gnu" \
    -DCMAKE_C_COMPILER="clang" \
    -DCMAKE_CXX_COMPILER="clang++" \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_GENERATOR=Ninja \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_BUILD_STATIC=ON \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_BUILD_LLVM_DYLIB=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_ENABLE_RTTI=OFF \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DCLANG_ENABLE_OBJC_REWRITER=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DLLVM_ENABLE_ASSERTIONS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_BUILD_RUNTIME=OFF \
    -DLLVM_BUILD_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_BUILD_INSTRUMENTED=OFF \
    -DLLVM_ENABLE_PROJECTS="${PROJECTS}" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
    -DLLVM_TOOLCHAIN_TOOLS="llvm-ar;llvm-ranlib;llvm-objdump;llvm-rc;llvm-nm;llvm-strings;llvm-readobj;llvm-objcopy;llvm-strip;llvm-addr2line;llvm-symbolizer;llvm-readelf;llvm-size;llvm-lib" \
    "${LTO[@]}" \
    ..

cmake --build .
cmake --install . --strip

rm -rf "${PREFIX:?}"/{libexec,share/{opt-viewer,scan-build,scan-view,man/man1/scan-build*},include/{clang,clang-c,clang-tidy,lld,llvm,llvm-c,lldb}}

find "${PREFIX:?}/bin" -mindepth 1 -maxdepth 1 \( \
    -name "amdgpu-arch" -o -name "bugpoint" -o -name "c-index-test" -o -name "clangd-*" -o \
    -name "darwin-debug" -o -name "diagtool" -o -name "dsymutil" -o -name "find-all-symbols" -o \
    -name "hmaptool" -o -name "ld64.lld*" -o -name "llc" -o -name "lldb-*" -o -name "lli" -o \
    -name "modularize" -o -name "nvptx-arch" -o -name "obj2yaml" -o -name "offload-arch" -o -name "opt" -o \
    -name "pp-trace" -o -name "sancov" -o -name "sanstats" -o -name "scan-build" -o \
    -name "scan-view" -o -name "split-file" -o -name "verify-uselistorder" -o -name "wasm-ld" -o \
    -name "yaml2*" -o -name "libclang.dll" -o -name "*LTO.dll" -o -name "*Remarks.dll" -o -name "*.bat" -o \
    \( -name "clang-*" ! -name "*[0-9]" ! -name "clang-scan-deps" ! -name "clang-cpp" ! -name "clang-format" \) \) -delete

find "${PREFIX:?}/lib" -mindepth 1 -maxdepth 1 \( \
    -name "*.so*" -o -name "*.dylib*" -o -name "cmake" -o \
    -name "*.a" -o -name "*.dll.a" \) -exec rm -rf {} +

find "${PREFIX:?}/share/clang" -mindepth 1 -maxdepth 1 ! -name "clang-format*" -exec rm -rf {} +

cp ../LICENSE.TXT "${PREFIX}/"
