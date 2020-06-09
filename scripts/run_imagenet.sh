#!/bin/bash
# imagenet correctness tests
set -x
MIGX=${MIGX:="/src/rocm-migraphx/tools/migx/build/migx"}
IMAGENET=${IMAGENET:="../datasets/imagenet"}
TEST_RESULTDIR=${TEST_RESULTDIR:="../test-results"}
MODELDIR=${MODELDIR:="../saved-models"}

testdir=${TEST_RESULTDIR}/imagenet-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir

while read tag typeopt model opts
do
    if [ "$tag" == "#" ]; then
	continue
    fi
    echo $tag
    ${MIGX} --imagenet ${IMAGENET} $typeopt ${MODELDIR}/$model $opts 2>${testdir}/${tag}.err | tee ${testdir}/${tag}.out
done<<EOF
resnet50v2-onnx --onnx torchvision/resnet50i1.onnx --argname input.1
inceptionv3-onnx --onnx torchvision/inceptioni1.onnx --argname x.1
resnet50v2-tf --tfpb slim/resnet50v2_i1.pb --argname input
mobilenet-tf --tfpb slim/mobilenet_i1.pb --argname input
EOF
