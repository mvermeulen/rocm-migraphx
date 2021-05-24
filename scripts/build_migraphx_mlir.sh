#!/bin/bash
#
# build migraphx in docker container
env HIP_DOCKER_WORKAROUND=${HIP_DOCKER_WORKAROUND:="0"}
cd /src/AMDMIGraphX
if [ -d build ]; then
    rm -rf build
fi
mkdir build
cd build
# workaround for hip packaging in docker
if [ -f '/opt/rocm/llvm/bin/clang++' ]; then
    env CXX=/opt/rocm/llvm/bin/clang++ CXXFLAGS="-O3" cmake -DMIGRAPHX_ENABLE_MLIR=ON ..    
elif [ "$HIP_DOCKER_WORKAROUND" = "1" ]; then
    env CXX=/opt/rocm/bin/hcc CXXFLAGS="-O3 -fno-gpu-rdc -amdgpu-target=gfx906" cmake ..
else
    env CXX=/opt/rocm/bin/hcc CXXFLAGS="-O3 -fno-gpu-rdc" cmake ..
fi

if [ "$LD_LIBRARY_PATH" = "" ]; then
    export LD_LIBRARY_PATH=/usr/local/lib:
fi

make -j4
