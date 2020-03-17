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
torchvision-resnet50         64 torchvision/resnet50i64.onnx
torchvision-resnet50_fp16    64 torchvision/resnet50i64.onnx --fp16
torchvision-alexnet          64 torchvision/alexneti64.onnx
torchvision-alexnet_fp16     64 torchvision/alexneti64.onnx --fp16
torchvision-densenet121      32 torchvision/densenet121i32.onnx
torchvision-densenet121      32 torchvision/densenet121i32.onnx --fp16
cadene-dpn92                 32 cadene/dpn92i32.onnx
cadene-fbresnet152           32 cadene/fbresnet152i32.onnx
torchvision-inceptionv3	     32 torchvision/inceptionv3i32.onnx
torchvision-inceptionv3_fp16 32 torchvision/inceptionv3i32.onnx --fp16
cadene-inceptionv4           16 cadene/inceptionv4i16.onnx
cadene-resnext64x4           16 cadene/resnext101_64x4di16.onnx
torchvision-vgg16            16 torchvision/vgg16i16.onnx
torchvision-vgg16_fp16       16 torchvision/vgg16i16.onnx --fp16

MODELLIST


