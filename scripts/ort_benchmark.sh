#!/bin/bash
set -x
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
EXEDIR=${EXEDIR:="/workspace/onnxruntime/onnxruntime/python/tools/transformers"}

testdir=${TEST_RESULTDIR}/onnxruntime-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir

cd ${EXEDIR}
while read model batch sequence precision
do
    tag="${model}-b${batch}-s${sequence}-p${precision}-rocm"
    python3 benchmark.py -g -b $batch -m $model --sequence_length $sequence --precision $precision --provider rocm --result_csv $testdir/${tag}-summary.csv --detail_csv $testdir/${tag}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    tag="${model}-b${batch}-s${sequence}-p${precision}-migraphx"
    python3 benchmark.py -o no_opt -g -b $batch -m $model --sequence_length $sequence --precision $precision --provider migraphx --result_csv $testdir/${tag}-summary.csv --detail_csv $testdir/${tag}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
done <<BMARK_LIST
bert-base-cased 1 128 fp16
bert-base-cased 16 128 fp16
gpt2 1 128 fp16
gpt2 16 128 fp16
BMARK_LIST
