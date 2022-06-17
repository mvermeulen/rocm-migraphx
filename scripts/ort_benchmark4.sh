#!/bin/bash
set -x
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
EXEDIR=${EXEDIR:="/workspace/onnxruntime/onnxruntime/python/tools/transformers"}
PYTHONPATH=${PYTHONPATH:="/workspace/migraphx/build/lib"}
export PYTHONPATH
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
python benchmark.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard-ep.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32,64,128
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 16 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard-ep.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.err
python benchmark.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard-ep.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# clear the cached optimized models
rm ./onnx_models/*gpu*

# Ideal batch: 1,2,4,8,16,32,64,128,256
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-base-cased migraphx engine\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased migraphx engine\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --engine=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard-eng.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32,64,128
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-large-uncased migraphx engine\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased migraphx engine\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 16 --engine=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard-eng.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** distilgpt2 migraphx engine\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 migraphx engine\n" >> $testdir/dashboard.err
python benchmark.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --engine=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard-eng.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# clear the cached optimized models
rm ./onnx_models/*gpu*

echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=rocm -p fp16 --result_csv $testdir/dashboard-rocm.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** bert-large-uncased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 16 --provider=rocm -p fp16 --result_csv $testdir/dashboard-rocm.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** distilgpt2 rocm\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 rocm\n" >> $testdir/dashboard.err
python benchmark.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=rocm -p fp16 --result_csv $testdir/dashboard-rocm.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err
