#!/bin/bash
set -x
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
EXEDIR=${EXEDIR:="/workspace/onnxruntime/onnxruntime/python/tools/transformers"}
MICROBENCH=${MICROBENCH:="/workspace/onnxruntime/onnxruntime/python/tools/microbench"}

testdir=${TEST_RESULTDIR}/onnxruntime-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
pushd /workspace/migraphx/src
git log > $testdir/commit.txt
popd
cd ${EXEDIR}
touch ${testdir}/summary.csv

# Ideal batch: 1,2,4,8,16,32,64,128,256
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-base-cased migraphx\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased migraphx\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32,64,128
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 32 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.err
python benchmark.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** bert-large-uncased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 32 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** distilgpt2 rocm\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

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

cd ${MICROBENCH}
while read bmark provider precision
do
    python3 ${bmark}.py --provider ${provider} --precision ${precision}
done 1>${testdir}/microbench.out 2>${testdir}/microbench.err <<BMARK_LIST
attention rocm fp16
attention rocm fp32
attention cpu fp32
fast_gelu rocm fp16
fast_gelu rocm fp32
fast_gelu cpu fp32
matmul rocm fp16
matmul rocm fp32
matmul cpu fp32
skip_layer_norm rocm fp16
skip_layer_norm rocm fp32
skip_layer_norm fp32
BMARK_LIST
