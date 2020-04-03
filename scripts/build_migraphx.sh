#!/bin/bash
#
# build migraphx in docker container
cd /src/AMDMIGraphX
if [ -d build ]; then
    rm -rf build
fi
mkdir build
cd build
#env CXX=/opt/rocm/bin/hcc CXXFLAGS="-O3 -fno-gpu-rdc -amdgpu-target=gfx906" cmake ..
env CXX=/opt/rocm/bin/hcc CXXFLAGS="-O3 -fno-gpu-rdc" cmake ..
if [ "$LD_LIBRARY_PATH" = "" ]; then
    export LD_LIBRARY_PATH=/usr/local/lib:
fi

make -j4
