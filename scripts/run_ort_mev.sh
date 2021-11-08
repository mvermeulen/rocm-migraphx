#!/bin/bash
#
# Run ONNX runtime performance/correctness tests.
#
# NOTE: This script should be run inside a docker container build using the
#       tools/onnxruntime directory scripts.
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
TESTDRIVER=${TESTDRIVER:="/home/mev/source/rocm-migraphx/tools/onnxruntime/run_onnx_test.sh"}
EXPROVIDER=${EXPROVIDER:="migraphx"}

cd ${TEST_RESULTDIR}
testdir=ort-${EXPROVIDER}-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
cd $testdir
echo $EXPROVIDER > exprovider.txt
ls /opt > opt.txt

while read testcase
do
    base=`basename $testcase`
    env TESTCASE=$testcase EXPROVIDER=$EXPROVIDER $TESTDRIVER
#    cat ${base}.suma | awk -F, '{ print $1 "," $2 }' | tee -a results.csv
#    cat ${base}.sumb | awk -F, '{ print $1 "," $2 }' | tee -a results.csv
#    cat ${base}.sumc | awk -F, '{ print $1 "," $2 }' | tee -a results.csv
    cat ${base}.sum  | awk -F, '{ print $1 "," $2 }' | tee -a results.csv    
done <<TESTLIST
single/cadene_resnet50
single/tf_resnet_v2_50
opset10/BERT_Squad
opset11/tf_resnet_v2_50
opset11/tf_inception_v4
opset11/tf_mobilenet_v2_1.4_224
opset10/faster_rcnn
opset10/mask_rcnn
opset10/mlperf_resnet
TESTLIST

