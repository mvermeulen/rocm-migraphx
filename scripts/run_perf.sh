#!/bin/bash
#
# saved model directory mounted to the docker image
SAVED_MODELS=${SAVED_MODELS:="../saved-models"}
TEST_RESULTDIR=${TEST_RESULTDIR:="../test-results"}

DRIVER=${DRIVER:="/src/AMDMIGraphX/build/bin/driver"}

# run predefined list of test files, all these relative to SAVED_MODELS dir
cd ${TEST_RESULTDIR}
testdir=results-`date '+%Y-%m-%d-%H-%m'`
mkdir $testdir
cd $testdir
while read tag batch savefile extra
do
    if [ "$tag" == "#" ]; then
	continue
    fi
    $DRIVER perf $extra $SAVED_MODELS/$savefile > ${tag}.out 2> ${tag}.err
    time=`grep 'Total time' ${tag}.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
    echo $tag,$batch,$time | tee results.csv
done <<MODELLIST
torchvision-resnet50i1        1 torchvision/resnet50i1.onnx
torchvision-resnet50i2        2 torchvision/resnet50i2.onnx
torchvision-resnet50i4        4 torchvision/resnet50i4.onnx
torchvision-resnet50i8        8 torchvision/resnet50i8.onnx
torchvision-resnet50i16      16 torchvision/resnet50i16.onnx
torchvision-resnet50i32      32 torchvision/resnet50i32.onnx
torchvision-resnet50i64      64 torchvision/resnet50i64.onnx
torchvision-resnet50i64_fp16 64 torchvision/resnet50i64.onnx --fp16
torchvision-alexnet          64 torchvision/alexneti64.onnx
torchvision-alexnet_fp16     64 torchvision/alexneti64.onnx --fp16
torchvision-densenet121      32 torchvision/densenet121i32.onnx
torchvision-densenet121_fp16 32 torchvision/densenet121i32.onnx --fp16
torchvision-vgg16            16 torchvision/vgg16i16i16.onnx
torchvision-vgg16_fp16       16 torchvision/vgg16i16i16.onnx --fp16
torchvision-inceptionv3      32 torchvision/inceptioni32.onnx
torchvision-inceptionv3_fp16 32 torchvision/inceptioni32.onnx --fp16
opset11-resnet50_v2_50-onnx   1 onnxruntime/opset11/tf_resnet_v2_50/model.onnx
opset11-inception_v4-onnx     1 onnxruntime/opset11/tf_inception_v4/model.onnx
# opset11-mobilenet-v2-1.4-onnx 1 onnxruntime/opset11/tf_mobilenet_v2_1.4_224/model.onnx
MODELLIST


