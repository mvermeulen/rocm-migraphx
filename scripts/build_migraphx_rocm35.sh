#!/bin/bash
cd /src/AMDMIGraphX
git checkout master
export LC_ALL=C.UTF-8
rbuild -d depend --cxx=/opt/rocm/llvm/bin/clang++
cd build
make | tee -a build.log
