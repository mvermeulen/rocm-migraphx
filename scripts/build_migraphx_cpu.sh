#!/bin/bash
#
# build migraphx in docker container
env HIP_DOCKER_WORKAROUND=${HIP_DOCKER_WORKAROUND:="0"}
cd /src/AMDMIGraphX
if [ -d build-cpu ]; then
    rm -rf build-cpu
fi
mkdir build-cpu
cd build-cpu
# workaround for hip packaging in docker
if [ -f '/opt/rocm/llvm/bin/clang++' ]; then
    env CXX=/opt/rocm/llvm/bin/clang++ CXXFLAGS="-O3" cmake -DMIGRAPHX_ENABLE_CPU=On ..    
fi

if [ "$LD_LIBRARY_PATH" = "" ]; then
    export LD_LIBRARY_PATH=/usr/local/lib:
fi

make -j4
