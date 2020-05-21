#!/bin/bash
cd /src/AMDMIGraphX
cd build
cmake CXX=/opt/rocm/llvm/bin/clang++ ..
make
