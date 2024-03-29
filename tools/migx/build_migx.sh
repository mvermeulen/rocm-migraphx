#!/bin/bash
#
# script to (re)build migx driver
if [ -d build ]; then
    rm -rf build
fi
mkdir build
cd build
if [ -f /opt/rocm/llvm/bin/clang++ ]; then
    env CXXFLAGS="-g -Wl,-allow-shlib-undefined" cmake -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ ..
else
    cmake -DCMAKE_CXX_COMPILER=/opt/rocm/bin/hcc CXXFLAGS="-I/usr/local/include" ..
fi
make

cd ..

if [ -d /src/AMDMIGraphX/build-cpu ]; then
    if [ -d build-cpu ]; then
	rm -rf build-cpu
    fi
    mkdir build-cpu
    cd build-cpu
    
    env CXXFLAGS="-Wl,-allow-shlib-undefined" cmake -DCMAKE_CXX_COMPILER=clang++ -DMIGRAPHX_BUILD=/src/AMDMIGraphX/build-cpu -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ ..

    make
fi

