#!/bin/bash
#
# build migraphx in docker container
cd /src/AMDMIGraphX
if [ -f build ]; then
    rm -rf build
fi
mkdir build
cd build
env CXX=/opt/rocm/bin/hcc CXXFLAGS="-O3" cmake ..
make
make check
