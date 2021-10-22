#!/bin/bash
# mnist test
set -x

MIGX=${MIGX:="/src/rocm-migraphx/tools/migx/build/migx"}
TEST_RESULTDIR=${TEST_RESULTDIR:="/src/test-results"}
MODELDIR=${MODELDIR:="/src/saved-models"}
MNISTDIR=${MNISTDIR:="/src/mnist"}

testdir=${TEST_RESULTDIR}/mnist-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir

${MIGX} --mnist ${MNISTDIR} --argname=0 --onnx=${MODELDIR}/pytorch-mnist.onnx 2>${testdir}/mnist-fp32.err | tee ${testdir}/mnist-fp32.out
${MIGX} --fp16 --mnist ${MNISTDIR} --argname=0 --onnx=${MODELDIR}/pytorch-mnist.onnx 2>${testdir}/mnist-fp16.err | tee ${testdir}/mnist-fp16.out

