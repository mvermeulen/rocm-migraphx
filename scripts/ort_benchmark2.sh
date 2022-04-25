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
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 1 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 2 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 4 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 8 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 16 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 32 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 64 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 128 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 256 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# clear the cached optimized models
rm ./onnx_models/*gpu*

echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 1 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 2 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 4 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 8 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 16 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 32 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 64 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 128 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 256 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
exit 1
echo "\n***** bert-base-cased cpu\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased cpu\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 1 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 2 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 4 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 8 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 16 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 32 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 64 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 128 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 16 32 64 128 256 384 512 --batch_sizes 256 --provider=cpu -p fp32 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
exit 1
