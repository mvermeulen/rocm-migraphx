#!/bin/bash
#
# Note: Requires cmake >= 3.13
#
if [ ! -d onnxruntime ]; then
    git clone --recursive https://github.com/microsoft/onnxruntime
else
    git pull
fi

cd onnxruntime
./build.sh --x86 --config RelWithDebInfo --build_shared_lib --parallel
