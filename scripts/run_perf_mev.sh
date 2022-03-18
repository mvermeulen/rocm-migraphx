#!/bin/bash
#
# saved model directory mounted to the docker image
SAVED_MODELS=${SAVED_MODELS:="/home/mev/source/rocm-migraphx/saved-models"}
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
AMDMIGRAPHX=${AMDMIGRAPHX:="/src/AMDMIGraphX"}
TARGETOPT=""
MIGX=${MIGX:="/src/rocm-migraphx/tools/migx/build/migx"}

if [ "$BUILD_NAVI" = "1" ]; then
    export MIGRAPHX_DISABLE_MIOPEN_FUSION=1
fi


if [ "$DRIVER" = "" ]; then
    if [ "$TARGET" = "cpu" ]; then
	DRIVER=${DRIVER:="${AMDMIGRAPHX}/build-cpu/bin/driver"}
	MIGX="/src/rocm-migraphx/tools/migx/build-cpu/migx"
	TARGETOPT="--cpu"
    else
	DRIVER=${DRIVER:="${AMDMIGRAPHX}/build/bin/driver"}
	TARGETOPT="--gpu"
    fi
fi
  
cd ${AMDMIGRAPHX}
commit=`git log | head -1 | awk '{ print $2 }'`
git log | head -5 > /tmp/commit.txt
echo `ls -d /opt/rocm*` > /tmp/rocm.txt
# run predefined list of test files, all these relative to SAVED_MODELS dir
cd ${TEST_RESULTDIR}
testdir=perf-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
cd $testdir
mv /tmp/commit.txt /tmp/rocm.txt .
echo $commit
while read tag batch savefile extra
do
    if [ "$tag" == "#" ]; then
	continue
    fi
    $DRIVER perf $extra $TARGETOPT $SAVED_MODELS/$savefile > ${tag}.out 2> ${tag}.err
    time=`grep 'Total time' ${tag}.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
    echo $tag,$batch,$time | tee -a results.csv
    if [ "$MEMORY" != "" ]; then
	/home/mev/source/rocm-migraphx/tools/memory/display_memory
    fi
done <<MODELLIST
torchvision-resnet50         64 torchvision/resnet50i64.onnx
torchvision-resnet50_fp16    64 torchvision/resnet50i64.onnx --fp16
torchvision-alexnet          64 torchvision/alexneti64.onnx
torchvision-alexnet_fp16     64 torchvision/alexneti64.onnx --fp16
torchvision-densenet121      32 torchvision/densenet121i32.onnx
torchvision-densenet121_fp16 32 torchvision/densenet121i32.onnx --fp16
torchvision-inceptionv3	     32 torchvision/inceptioni32.onnx
torchvision-inceptionv3_fp16 32 torchvision/inceptioni32.onnx --fp16
torchvision-vgg16            16 torchvision/vgg16i16.onnx
torchvision-vgg16_fp16       16 torchvision/vgg16i16.onnx --fp16
cadene-inceptionv4           16 cadene/inceptionv4i16.onnx
cadene-resnext64x4           16 cadene/resnext101_64x4di16.onnx
slim-mobilenet               64 slim/mobilenet_i64.pb
slim-nasnetalarge            64 slim/nasnet_i64.pb
slim-resnet50v2              64 slim/resnet50v2_i64.pb
MODELLIST

# Run models that require MIGX driver
${MIGX} $TARGETOPT --glue=MRPC --gluefile=../../datasets/glue/MRPC.tst --onnx ${SAVED_MODELS}/huggingface-transformers/bert_mrpc8.onnx --perf_report > bert_mrpc8.out
time=`grep 'Total time' bert_mrpc8.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
echo "bert-mrpc-onnx,8,$time" |  tee -a results.csv
${MIGX} $TARGETOPT --glue=MRPC --gluefile=../../datasets/glue/MRPC.tst --tfpb ${SAVED_MODELS}/tf-misc/bert_mrpc1.pb --perf_report > bert_mrpc1.out
time=`grep 'Total time' bert_mrpc1.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
echo "bert-mrpc-tf,1,$time" |  tee -a results.csv
${MIGX} $TARGETOPT --zero_input --onnx $SAVED_MODELS/pytorch-examples/wlang_gru.onnx --perf_report --argname=input.1 > wlang_gru.out
time=`grep 'Total time' wlang_gru.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
echo "pytorchexamples-wlang-gru,1,$time" |  tee -a results.csv
${MIGX} $TARGETOPT --zero_input --onnx $SAVED_MODELS/pytorch-examples/wlang_lstm.onnx --perf_report --argname=input.1 > wlang_lstm.out
time=`grep 'Total time' wlang_lstm.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
echo "pytorchexamples-wlang-lstm,1,$time" | tee -a results.csv

# Run models with batch size 1
while read tag batch savefile extra
do
    if [ "$tag" == "#" ]; then
	continue
    fi
    $DRIVER perf $TARGETOPT $SAVED_MODELS/$savefile $extra > ${tag}.out 2> ${tag}.err
    time=`grep 'Total time' ${tag}.out | awk '{ print $3 }' | sed s/ms//g` >/dev/null 2>&1
    echo $tag,$batch,$time | tee -a results.csv
done <<MODELLIST
torchvision-resnet50_1         1 torchvision/resnet50i1.onnx
torchvision-inceptionv3_1      1 torchvision/inceptioni1.onnx
torchvision-vgg16_1            1 torchvision/vgg16i1.onnx
cadene-dpn92_1                 1 cadene/dpn92i1.onnx
cadene-resnext101_1            1 cadene/resnext101_64x4di1.onnx
slim-vgg16_1                   1 slim/vgg16_i1.pb
slim-mobilenet_1               1 slim/mobilenet_i1.pb
slim-inceptionv4_1             1 slim/inceptionv4_i1.pb
onnx-taau-downsample	       1 onnx-misc/taau_low_res_downsample_d2s_for_infer_time_fp16_opset11.onnx --input-dim @inputs 1 1920 1080 8
# mlperf-3dunet		       1 onnx-misc/224_224_160.onnx
MODELLIST
