#!/bin/bash
# imagenet correctness tests
MIGX=${MIGX:="../tools/migx/build/migx"}
IMAGENET=${IMAGENET:="../datasets/imagenet"}
MODELDIR=${MODELDIR:="../saved-models"}

while read tag typeopt model opts
do
    if [ "$tag" == "#" ]; then
	continue
    fi
    echo $tag
    ${MIGX} --imagenet ${IMAGENET} $typeopt ${MODELDIR}/$model $opts 2>${tag}.err | tee ${tag}.out
done<<EOF
resnet50v2-onnx --onnx torchvision/resnet50i1.onnx --argname input.1
inceptionv3-onnx --onnx torchvision/inceptioni1.onnx --argname input.1
resnet50v2-tf --tfpb slim/resnet50v2_i1.pb --argname input
mobilenet-tf --tfpb slim/mobilenet_i1.pb --argname input
EOF
