#!/bin/bash
cd /src/AMDMIGraphX

# work around broken rocblas header file
sed -i 's/rocblas-types.h/rocblas.h/g' /src/AMDMIGraphX/src/targets/gpu/gemm_impl.cpp
git checkout master
export LC_ALL=C.UTF-8
rbuild build -d depend --cxx=/opt/rocm/llvm/bin/clang++
cd build
make -j4 | tee -a build.log
