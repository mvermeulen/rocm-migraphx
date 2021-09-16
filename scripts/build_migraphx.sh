#!/bin/bash
#
# build migraphx in docker container
CMAKEFLAGS=${CMAKEFLAGS:=""}
BUILD_NAVI=${BUILD_NAVI:="0"}
if [ "$BUILD_NAVI" == 0 ]; then
    BUILD_FLAGS=""
else
    BUILD_FLAGS="-DAMDGPU_TARGETS=gfx1030 -DGPU_TARGETS=gfx1030 -DCMAKE_CXX_FLAGS=-DMIGRAPHX_NO_DPP"
fi

env USE_RBUILD=${USE_RBUILD:="0"}
cd /src/AMDMIGraphX
if [ "$USE_RBUILD" = "0" ]; then
    if [ -d build ]; then
	rm -rf build
    fi
    mkdir build
    cd build
    # workaround for hip packaging in docker
    if [ -f '/opt/rocm/llvm/bin/clang++' ]; then
	env CXX=/opt/rocm/llvm/bin/clang++ CXXFLAGS="-O3" cmake $CMAKEFLAGS $BUILD_FLAGS ..
    else
	echo "Missing clang++"
	exit 1
    fi

    if [ "$LD_LIBRARY_PATH" = "" ]; then
	export LD_LIBRARY_PATH=/usr/local/lib:
    fi

    make -j4
else
    pip3 install https://github.com/RadeonOpenCompute/rbuild/archive/master.tar.gz
    rbuild build -d depend -B build $BUILD_FLAGS $CMAKEFLAGS --cxx=/opt/rocm/llvm/bin/clang++
fi

