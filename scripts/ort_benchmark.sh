#!/bin/bash
set -x
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
EXEDIR=${EXEDIR:="/workspace/onnxruntime/onnxruntime/python/tools/transformers"}

testdir=${TEST_RESULTDIR}/onnxruntime-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
pushd /workspace/migraphx/src
git log > $testdir/commit.txt
popd
cd ${EXEDIR}
touch ${testdir}/summary.csv
while read model batch sequence precision
do
    file="${model}-b${batch}-s${sequence}-${precision}"
    tag="${model}-b${batch}-s${sequence}-${precision}-rocm"
    python3 benchmark.py -g -b $batch -m $model --sequence_length $sequence --precision $precision --provider rocm --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    tag="${model}-b${batch}-s${sequence}-${precision}-migraphx"
    python3 benchmark.py -o no_opt -g -b $batch -m $model --sequence_length $sequence --precision $precision --provider migraphx --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    if [ "$precision" = "fp32" ]; then
	tag="${model}-b${batch}-s${sequence}-${precision}-torch"	
	python3 benchmark.py -o no_opt -b $batch -m $model --sequence_length $sequence --precision $precision -e torch --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
	tag="${model}-b${batch}-s${sequence}-${precision}-torchscript"	
	python3 benchmark.py -o no_opt -b $batch -m $model --sequence_length $sequence --precision $precision -e torchscript --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
	tag="${model}-b${batch}-s${sequence}-${precision}-cpu"		
	python3 benchmark.py -o no_opt -b $batch -m $model --sequence_length $sequence --precision $precision -e cpu --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err	
    fi
    sort -ru $testdir/${file}-detail.csv > ${testdir}/${file}-detail-sort.csv
    sort -ru $testdir/${file}-summary.csv > ${testdir}/${file}-summary-sort.csv
    cat ${testdir}/${file}-summary-sort.csv >> ${testdir}/summary.csv
done <<BMARK_LIST
bert-base-cased 1 128 fp16
bert-base-cased 1 128 fp32
bert-large-uncased 1 128 fp16
bert-large-uncased 1 128 fp32
distilgpt2 1 128 fp16
distilgpt2 1 128 fp32
facebook/bart-base 1 128 fp16
facebook/bart-base 1 128 fp32
gpt2 1 128 fp16
gpt2 1 128 fp32
microsoft/DialoGPT-medium 1 128 fp16
microsoft/DialoGPT-medium 1 128 fp16
roberta-base 1 128 fp16
roberta-base 1 128 fp32
BMARK_LIST
sort -ru ${testdir}/summary.csv > ${testdir}/results.csv

