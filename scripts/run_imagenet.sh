#!/bin/bash
# imagenet correctness tests
set -x
QUANTIZE=${QUANTIZE:=""}
MIGX=${MIGX:="/src/rocm-migraphx/tools/migx/build/migx"}
IMAGENET=${IMAGENET:="../datasets/imagenet"}
TEST_RESULTDIR=${TEST_RESULTDIR:="../test-results"}
MODELDIR=${MODELDIR:="../saved-models"}

if [ "$BUILD_NAVI" = "1" ]; then
    export MIGRAPHX_DISABLE_MIOPEN_FUSION=1
fi

testdir=${TEST_RESULTDIR}/imagenet-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir

while read tag typeopt model opts
do
    if [ "$tag" == "#" ]; then
	continue
    fi
    echo $tag
    ${MIGX} --imagenet ${IMAGENET} $typeopt ${MODELDIR}/$model ${QUANTIZE} $opts 2>${testdir}/${tag}.err | tee ${testdir}/${tag}.out
done<<EOF
resnet50v2-onnx --onnx torchvision/resnet50i1.onnx --argname input.1
inceptionv3-onnx --onnx torchvision/inceptioni1.onnx --argname x.1
resnet50v2-tf --tfpb slim/resnet50v2_i1.pb --argname input
mobilenet-tf --tfpb slim/mobilenet_i1.pb --argname input
EOF

# Extra models that also have good accuracy behavior
# alexnet-onnx --onnx torchvision/alexneti1.onnx --argname input.1
# densenet-onnx --onnx torchvision/densenet121i1.onnx --argname input.1
# vgg16-onnx --onnx torchvision/vgg16i1.onnx --argname input.1
# dpn92-onnx --onnx cadene/dpn92i1.onnx --argname 0
# resnext101-onnx --onnx cadene/resnext101_64x4di1.onnx --argname 0
# inceptionv4-tf --tfpb slim/inceptionv4_i1.pb --argname input
