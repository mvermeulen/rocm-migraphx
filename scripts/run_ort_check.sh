#!/bin/bash
#
# Run ONNX runtime performance/correctness tests.
#
# NOTE: This script should be run inside a docker container build using the
#       tools/onnxruntime directory scripts.
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
TESTDRIVER=${TESTDRIVER:="/home/mev/source/rocm-migraphx/tools/onnxruntime/run_onnx_test.sh"}
EXPROVIDER=${EXPROVIDER:="migraphx"}
ITERATIONS=${ITERATIONS:="100"}

cd ${TEST_RESULTDIR}
testdir=ort-${EXPROVIDER}-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
cd $testdir
echo $EXPROVIDER > exprovider.txt

while read testcase
do
    base=`basename $testcase`
    dir=`dirname $testcase`
    env TESTCASE=$testcase PREFIX="${dir}@" ITERATIONS=$ITERATIONS $TESTDRIVER
    cat ${dir}@${base}.sum | sed -e 's?@?/?g' | tee -a results.csv
done <<TESTLIST
opset10/tf_resnet_v1_101
opset10/mlperf_mobilenet
opset10/tf_inception_v2
opset10/tf_mobilenet_v2_1.4_224
opset10/tf_mobilenet_v2_1.0_224
opset10/tf_inception_v3
opset10/mask_rcnn_keras
opset10/tf_resnet_v2_101
opset10/mask_rcnn
opset10/tf_resnet_v2_50
opset10/tf_inception_v4
opset10/tf_resnet_v1_50
opset10/tf_inception_resnet_v2
opset10/mlperf_ssd_mobilenet_300
opset10/mlperf_resnet
opset10/yolov3
opset10/tf_pnasnet_large
opset10/tf_inception_v1
opset10/tf_nasnet_mobile
opset10/faster_rcnn
opset10/mlperf_ssd_resnet34_1200
opset10/BERT_Squad
opset10/tf_nasnet_large
opset10/tf_mobilenet_v1_1.0_224
opset10/tf_resnet_v2_152
opset10/tf_resnet_v1_152
inferred/mask_rcnn
inferred/faster_rcnn
inferred/BERT_Squad
opset9/tf_resnet_v1_101
opset9/candy
opset9/tf_inception_v2
opset9/rain_princess
opset9/tf_mobilenet_v2_1.4_224
opset9/mosaic
opset9/tf_mobilenet_v2_1.0_224
opset9/tf_inception_v3
opset9/tf_resnet_v2_101
opset9/tf_resnet_v2_50
opset9/tf_inception_v4
opset9/cgan
opset9/tf_resnet_v1_50
opset9/tf_inception_resnet_v2
opset9/tf_pnasnet_large
opset9/tf_inception_v1
opset9/LSTM_Seq_lens_unpacked
opset9/tf_nasnet_mobile
opset9/tf_nasnet_large
opset9/pointilism
opset9/tf_mobilenet_v1_1.0_224
opset9/udnie
opset9/tf_resnet_v2_152
opset9/tf_resnet_v1_152
opset7/tf_resnet_v1_101
opset7/test_squeezenet
opset7/test_inception_v1
opset7/tf_inception_v2
opset7/tf_mobilenet_v2_1.4_224
opset7/test_resnet18v2
opset7/tf_mobilenet_v2_1.0_224
opset7/test_resnet50
opset7/test_bvlc_googlenet
opset7/tf_inception_v3
opset7/test_vgg19
opset7/test_resnet152v2
opset7/tf_resnet_v2_101
opset7/test_densenet121
opset7/tf_resnet_v2_50
opset7/tf_inception_v4
opset7/test_mobilenetv2-1.0
opset7/test_bvlc_reference_rcnn_ilsvrc13
opset7/test_mnist
opset7/tf_resnet_v1_50
opset7/test_resnet50v2
opset7/tf_inception_resnet_v2
opset7/test_emotion_ferplus
opset7/test_bvlc_reference_caffenet
opset7/fp16_inception_v1
opset7/test_resnet34v2
opset7/test_resnet34v2
opset7/fp16_shufflenet
opset7/test_inception_v2
opset7/tf_pnasnet_large
opset7/tf_inception_v1
opset7/test_tiny_yolov2
opset7/test_zfnet512
opset7/tf_nasnet_mobile
opset7/tf_nasnet_large
opset7/tf_mobilenet_v1_1.0_224
opset7/test_bvlc_alexnet
opset7/test_squeezenet1.1
opset7/tf_resnet_v2_152
opset7/tf_resnet_v1_152
opset7/test_shufflenet
opset7/fp16_tiny_yolov2
opset7/test_resnet101v2
opset8/tf_resnet_v1_101
opset8/test_squeezenet
opset8/test_inception_v1
opset8/tf_inception_v2
opset8/tf_mobilenet_v2_1.4_224
opset8/tf_mobilenet_v2_1.0_224
opset8/test_resnet50
opset8/test_bvlc_googlenet
opset8/tf_inception_v3
opset8/test_vgg19
opset8/tf_resnet_v2_101
opset8/test_densenet121
opset8/tf_resnet_v2_50
opset8/tf_inception_v4
opset8/test_bvlc_reference_rcnn_ilsvrc13
opset8/test_mnist
opset8/tf_resnet_v1_50
opset8/tf_inception_resnet_v2
opset8/test_emotion_ferplus
opset8/test_bvlc_reference_caffenet
opset8/fp16_inception_v1
opset8/fp16_shufflenet
opset8/test_inception_v2
opset8/tf_pnasnet_large
opset8/tf_inception_v1
opset8/test_tiny_yolov2
opset8/test_zfnet512
opset8/tf_nasnet_mobile
opset8/mxnet_arcface
opset8/tf_nasnet_large
opset8/tf_mobilenet_v1_1.0_224
opset8/test_bvlc_alexnet
opset8/tf_resnet_v2_152
opset8/tf_resnet_v1_152
opset8/test_shufflenet
opset8/fp16_tiny_yolov2
opset11/tf_resnet_v1_101
opset11/tf_inception_v2
opset11/tf_mobilenet_v2_1.4_224
opset11/tf_mobilenet_v2_1.0_224
opset11/tf_inception_v3
opset11/tf_resnet_v2_101
opset11/tf_resnet_v2_50
opset11/tf_inception_v4
opset11/tf_resnet_v1_50
opset11/tf_inception_resnet_v2
opset11/tf_pnasnet_large
opset11/tf_inception_v1
opset11/tf_nasnet_mobile
opset11/tinyyolov3
opset11/tf_nasnet_large
opset11/tf_mobilenet_v1_1.0_224
opset11/tf_resnet_v2_152
opset11/tf_resnet_v1_152
TESTLIST

