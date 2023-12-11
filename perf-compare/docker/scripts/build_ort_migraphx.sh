#!/bin/bash
ORT_REPOSITORY=${ORT_REPOSITORY:="https://github.com/mvermeulen/onnxruntime"}
ORT_BRANCH=${ORT_BRANCH:="mev_add_shark"}
ROCM_VERSION=${ROCM_VERSION:="5.7.1"}
WORKDIR=${WORKSPACE:="/workdir"}

pip3 install packaging

# update cmake
CMAKE_VERSION=3.26.6
cd /usr/local && \
    wget -q -O - https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz | tar zxf -
export PATH=/usr/local/cmake-${CMAKE_VERSION}-linux-x86_64/bin:$PATH

# build ONNX runtime
cd /src
git clone --recursive --branch ${ORT_BRANCH} --depth=1 ${ORT_REPOSITORY}
cd onnxruntime
./build.sh --parallel --cmake_extra_defines ONNXRUNTIME_VERSION=`cat ./VERSION_NUMBER` CMAKE_HIP_FLAGS=-Wno-deprecated-builtins --config Release --skip_tests --build_wheel --use_migraphx --use_rocm --rocm_version=5.7.1 --rocm_home /opt/rocm --allow_running_as_root

pip3 install /src/onnxruntime/build/Linux/Release/dist/*.whl

# set up python environment
cd /src/onnxruntime/onnxruntime/python/tools/transformers
pip3 install -r requirements.txt
pip3 uninstall -y torch
pip3 install torch --index-url https://download.pytorch.org/whl/nightly/rocm5.7
pip3 install tensorflow-rocm
