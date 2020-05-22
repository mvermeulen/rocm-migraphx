#!/bin/bash
#
# script to (re)build migx driver
if [ -d build ]; then
    rm -rf build
fi
mkdir build
cd build
if [ -f /root/hip-clang ]; then
    cmake -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ ..
else
    cmake -DCMAKE_CXX_COMPILER=/opt/rocm/bin/hcc ..
fi
make
