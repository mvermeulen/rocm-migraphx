#!/bin/bash
#
# Quick tests for running ONNX runtime.
#
# Assumes the following setup:
#
# 1. Testing script added
#
#    git clone https://github.com/mvermeulen/ort_test /workspace/ort_test
#       a clone from 
#    git clone https://github.com/scxiao/ort_test /workspace/ort_test
#
# 2. ONNX runtime inference examples installed
#
#    git clone https://github.com/microsoft/onnxruntime-inference-examples /workspace/onnxruntime-inference-examples
#
# 2. Python environment installed
#
#    pip3 install onnx
#    pip3 install onnxruntime-rocm
#
# 3. MIGraphX built and installed as an execution provider for ONNX runtime

PYTHON_DRIVER=${PYTHON_DRIVER:="/workspace/ort_test/python/run_onnx/test_run_onnx.py"}
MODELDIR=${MODELDIR:="/home/mev/source/rocm-migraphx/saved-models/onnxruntime"}
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}

testdir=${TEST_RESULTDIR}/ort_test-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir

while read tag model options
do
    echo $model
    python3 ${PYTHON_DRIVER} ${MODELDIR}/$model $options 1>$testdir/$tag.out 2>$testdir/$tag.err
    python3 ${PYTHON_DRIVER} ${MODELDIR}/$model $options 1>$testdir/$tag.out 2>$testdir/$tag.err
done <<MODELLIST
resnet50      opset11/tf_resnet_v2_50/model.onnx     
resnet50-int8 opset11/tf_resnet_v2_50/model.onnx --quantize
MODELLIST

