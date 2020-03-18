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
    echo $tag,$batch,$time | tee -a results.csv
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
bert-mrpc-onnx                8 huggingface-transformers/bert_mrpc8.onnx
bert-mrpc-tf                  1 tf-misc/bert-mrpc1.pb
slim-mobilenet               64 slim/mobilenet_i64.pb
slim-nasnetalarge            16 slim/nasnet_i16.pb
slim-resnet50v2              64 slim/resnet50v2_i64.pb
MODELLIST

MIGX=${MIGX:="../tools/migx/build/migx"}
${MIGX} --zero_input --onnx $SAVED_MODELS/pytorch-examples/wlang_gru.onnx --perf_report --argname=input.1 > wlang_gru.out
time=`grep 'Total time' wlang_gru.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
echo "pytorchexamples-wlang-gru,1,$time" |  | tee -a results.csv
${MIGX} --zero_input --onnx $SAVED_MODELS/pytorch-examples/wlang_lstm.onnx --perf_report --argname=input.1 > wlang.lstm.out
time=`grep 'Total time' wlang_lstm.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
echo "pytorchexamples-wlang-lstm,1,$time" |  | tee -a results.csv


