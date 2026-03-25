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

for dep in git cmake clang gmake ninja; do
    if ! command -v "${dep}" >/dev/null; then
        echo "${dep} not installed. Please install it and retry" 1>&2
        exit 1
    fi
done

# Build initial toolchain that we will remove later
# This is required because Linux distributions tie LLVM to GCC
./build-musl.sh "${PREFIX}-stage1"
./build-llvm.sh "${PREFIX}-stage1"

# Forces compiler to link with compiler-rt libunwind and libc++
cp -rLv "cfg/x86_64-unknown-linux-gnu.cfg" "${PREFIX}-stage1/bin/"
export PATH="${PREFIX}-stage1/bin:${PATH}"

# Build the final toolchain without any dependency for GCC
# This adds:
#   -DLLVM_ENABLE_LIBCXX=ON
#   -DLLVM_STATIC_LINK_CXX_STDLIB=ON
./build-musl.sh "${PREFIX}-final"
./build-final.sh "${PREFIX}-final"

# Remove initial toolchain
rm -rf "${PREFIX:?}-stage1"
cp -rLv "cfg/x86_64-unknown-linux-gnu.cfg" "${PREFIX}-final/bin/"
mv -v "${PREFIX}-final" "${PREFIX}"
