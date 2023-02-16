#!/bin/bash
#
# build migraphx in docker container
env USE_RBUILD=${USE_RBUILD:="1"}
cd /src/AMDMIGraphX
if [ "$USE_RBUILD" = "0" ]; then
    if [ -d build ]; then
	rm -rf build
    fi
    mkdir build
    cd build
    # workaround for hip packaging in docker
    if [ -f '/opt/rocm/llvm/bin/clang++' ]; then
	env CXX=/opt/rocm/llvm/bin/clang++ CXXFLAGS="-O3" cmake -DMIGRAPHX_ENABLE_MLIR=ON ..    
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
    rbuild build -d depend -B build -DMIGRAPHX_ENABLE_MLIR=ON --cxx=/opt/rocm/llvm/bin/clang++
fi

