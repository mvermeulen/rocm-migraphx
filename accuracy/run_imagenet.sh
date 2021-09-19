#!/bin/bash
# imagenet correctness tests
set -x
MIGX=${MIGX:="/src/rocm-migraphx/tools/migx/build/migx"}
IMAGENET=${IMAGENET:="/src/imagenet"}
TEST_RESULTDIR=${TEST_RESULTDIR:="/src/test-results"}
MODELDIR=${MODELDIR:="/src/saved-models"}

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
resnet50v2-onnx --onnx resnet50i1.onnx --argname input.1
inceptionv3-onnx --onnx inceptioni1.onnx --argname x.1
resnet50v2-tf --tfpb resnet50v2_i1.pb --argname input
mobilenet-tf --tfpb mobilenet_i1.pb --argname input
alexnet-onnx --onnx alexneti1.onnx --argname input.1
densenet-onnx --onnx densenet121i1.onnx --argname input.1
vgg16-onnx --onnx vgg16i1.onnx --argname input.1
dpn92-onnx --onnx dpn92i1.onnx --argname 0
resnext-onnx --onnx resnext101_64x4di1.onnx --argname 0
inceptionv4-tf --tfpb inceptionv4_i1.pb --argname input
resnet50v2-onnx-fp16 --onnx resnet50i1.onnx --argname input.1 --fp16
inceptionv3-onnx-fp16 --onnx inceptioni1.onnx --argname x.1 --fp16
resnet50v2-tf-fp16 --tfpb resnet50v2_i1.pb --argname input --fp16
mobilenet-tf-fp16 --tfpb mobilenet_i1.pb --argname input --fp16
alexnet-onnx-fp16 --onnx alexneti1.onnx --argname input.1 --fp16
densenet-onnx-fp16 --onnx densenet121i1.onnx --argname input.1 --fp16
vgg16-onnx-fp16 --onnx vgg16i1.onnx --argname input.1 --fp16
dpn92-onnx-fp16 --onnx dpn92i1.onnx --argname 0 --fp16
resnext-onnx-fp16 --onnx resnext101_64x4di1.onnx --argname 0 --fp16
inceptionv4-tf-fp16 --tfpb inceptionv4_i1.pb --argname input --fp16
EOF
