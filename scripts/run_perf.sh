#!/bin/bash
#
# saved model directory mounted to the docker image
SAVED_MODELS=${SAVED_MODELS:="/media/mev/EXTRA/rocm-migraphx/saved-models"}
TEST_RESULTDIR=${TEST_RESULTDIR:="/media/mev/EXTRA/rocm-migraphx/test-results"}

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
opset11-resnet50_v2_50-onnx   1 onnxruntime/opset11/tf_resnet_v2_50/model.onnx
opset11-inception_v4-onnx     1 onnxruntime/opset11/tf_inception_v4/model.onnx
# opset11-mobilenet-v2-1.4-onnx 1 onnxruntime/opset11/tf_mobilenet_v2_1.4_224/model.onnx
MODELLIST


