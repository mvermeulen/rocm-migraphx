#!/bin/bash
RELEASE=${RELEASE:="2.3.0"}
git clone https://github.com/ROCmSoftwarePlatform/MIOpen
cd MIOpen
git checkout $RELEASE
cmake -P install_deps.cmake --minimum --prefix /usr/local
mkdir build
cd build
env CXX=/opt/rocm/hcc/bin/hcc cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hcc;/opt/rocm/hip" ..
make

