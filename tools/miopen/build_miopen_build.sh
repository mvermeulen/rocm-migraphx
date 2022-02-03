#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
INSTALL_PREFIX=${INSTALL_PREFIX:=""}

cd MIOpen
mkdir build
cd build

if [ "$INSTALL_PREFIX" != "" ]; then
    env CXX=/opt/rocm/llvm/bin/clang++ cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hip" cmake ..
    make
    make MIOpenDriver
elif [ "$INSTALL_PREFIX" == "default" ]; then
    env CXX=/opt/rocm/llvm/bin/clang++ cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hip" cmake ..
    make
    make MIOpenDriver
    make install
else
    env CXX=/opt/rocm/llvm/bin/clang++ cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hip" -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" cmake ..
    make
    make MIOpenDriver
    make install
fi

