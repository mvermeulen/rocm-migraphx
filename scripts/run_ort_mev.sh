#!/bin/bash
#
# Run ONNX runtime performance/correctness tests.
#
# NOTE: This script should be run inside a docker container build using the
#       tools/onnxruntime directory scripts
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
TESTDRIVER=${TESTDRIVER:="/home/mev/source/rocm-migraphx/tools/onnxruntime/run_onnx_test.sh"}

cd ${TEST_RESULTDIR}
testdir=ort-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
cd $testdir

while read testcase
do
    echo $testcase
    env TESTCASE=$testcase $TESTDRIVER
done <<TESTLIST
opset10/BERT_Squad
opset11/tf_resnet_v2_50
opset11/tf_inception_v4
opset11/tf_mobilenet_v2_1.4._224
opset10/faster_rcnn
opset10/mask_rcnn
opset10/mlperf_resnet
TESTLIST
