#!/bin/bash
set -x
rm -rf onnxruntime.save
mv onnxruntime onnxruntime.save
git clone --recursive https://github.com/microsoft/onnxruntime
patch onnxruntime/dockerfiles/Dockerfile.tensorrt < patch.tensorrt 
patch onnxruntime/dockerfiles/Dockerfile.cuda < patch.cuda
patch onnxruntime/dockerfiles/Dockerfile.openvino < patch.openvino
patch onnxruntime/dockerfiles/Dockerfile.migraphx < patch.migraphx
