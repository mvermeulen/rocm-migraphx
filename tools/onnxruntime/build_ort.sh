#!/bin/bash
REPOSITORY=${REPOSITORY:="https://github.com/microsoft/onnxruntime"}

if [ ! -d onnxruntime ]; then
    git clone ${REPOSITORY}
    cd onnxruntime
else
    cd onnxruntime
    git pull
fi

