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
