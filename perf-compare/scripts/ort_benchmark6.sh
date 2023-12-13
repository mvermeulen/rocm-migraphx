#!/bin/bash
set -x
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
EXEDIR=${EXEDIR:="/src/onnxruntime/onnxruntime/python/tools/transformers"}
MICROBENCH=${MICROBENCH:="/src/onnxruntime/onnxruntime/python/tools/microbench"}

testdir=${TEST_RESULTDIR}/onnxruntime-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
pushd /src/AMDMIGraphX/src
git log > $testdir/commit.txt
arch=`rocminfo | grep gfx | head -1 | awk '{ print $2 }'`
echo $arch > $testdir/arch.txt
if [ "$arch" = "gfx1034" ]; then
    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    arch=`rocminfo | grep gfx | head -1 | awk '{ print $2 }'`
    echo $arch " overridden" >> $testdir/arch.txt
fi
popd
cd ${EXEDIR}
touch ${testdir}/summary.csv

ENGINES=('torchscript')
PROVIDERS=('rocm' 'migraphx' 'cpu')

while read model batch sequence precision
do
    for engine in "${ENGINES[@]}"
    do
	file="${model}-b${batch}-s${sequence}-${precision}-${engine}"    
	case $engine in
	    "onnxruntime")
		for provider in "${PROVIDERS[@]}"
		do
		    tag="${file}-${provider}"
		    case $provider in
			"cpu")
			    options="-e onnxruntime --provider cpu"			    
			;;
			"migraphx")
			    options="-g -e onnxruntime --provider migraphx --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu"
			;;
			"rocm")
			    options="-g -e onnxruntime --provider rocm"
			;;
		    esac
		    echo "*** python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
		    /usr/bin/time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
		    sort -ru ${testdir}/${file}-detail.csv > ${testdir}/${file}-detail-sort.csv
		    sort -ru ${testdir}/${file}-summary.csv > ${testdir}/${file}-summary-sort.csv
		    cat ${testdir}/${file}-summary-sort.csv >> ${testdir}/summary.csv
		done
		continue
		;;
	    "torch")
		tag="${file}-${engine}"
		options="-g -o no_opt -e torch"		
		;;
	    "torch2")
		tag="${file}-${engine}"
		options="-g -o no_opt -e torch2"		
		;;
	    "torchscript")
		tag="${file}-${engine}"
		options="-g -o no_opt -e torchscript"		
		;;
	    "tensorflow")
		tag="${file}-${engine}"
		options="-g -o no_opt -e tensorflow"		
		;;
	    "shark")
		tag="${file}-${engine}"
		options="-g -o no_opt -e shark"
		;;    
	esac
	echo "*** python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
	/usr/bin/time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
	sort -ru ${testdir}/${file}-detail.csv > ${testdir}/${file}-detail-sort.csv
	sort -ru ${testdir}/${file}-summary.csv > ${testdir}/${file}-summary-sort.csv
	cat ${testdir}/${file}-summary-sort.csv >> ${testdir}/summary.csv
    done
done <<EOF    
bert-base-uncased 1 128 fp16
bert-base-uncased 1 128 fp32
bert-base-cased 1 32 fp16
bert-base-cased 1 384 fp16
bert-base-cased 32 32 fp16
bert-base-cased 32 384 fp16
bert-large-uncased 1 32 fp16
bert-large-uncased 1 384 fp16
bert-large-uncased 32 32 fp16
bert-large-uncased 32 384 fp16
distilgpt2 1 32 fp16
distilgpt2 1 384 fp16
distilgpt2 32 32 fp16
distilgpt2 32 384 fp16
EOF

# Temporary
# Run SHARK separately SHARK manages a separate python venv
# This means we might need to reinstall some python packages previously installed.
pushd /src/SHARK
export PYTHONPATH=/src/SHARK:$PYTHONPATH
# ONNX runtime benchmarks checks for a GPU version of torch and shark loads a CPU version
PYTHON=python3.11 ./setup_venv.sh
source shark.venv/bin/activate
pip3 install /src/onnxruntime/build/Linux/Release/dist/*.whl
pip3 install onnx
# Hack...
# 1. torch-mlir pulled in as a dependency by shark indirectly pulls in the CPU version
#    of torch from https://llvm.github.io/torch-mlir/package-index/.
# 2. We need the GPU version running in the ONNX benchmark.py script.  Rather than building
#    we try downloading the corresponding version from
#    https://download.pytorch.org/whl/nightly/rocm5.7/torch/
# 3. The version of torch built nightly doesn't necessarily have a corresponding torch-triton
#    so for now we pass the --no-dependencies flag.
# Hopefully not more is broken than the triton side...
required_torch_version=`pip3 list | grep "^torch " | awk '{ print $2 }' | sed -e 's/cpu/rocm5.7/g'`
pip3 install torch==${required_torch_version} -f https://download.pytorch.org/whl/nightly/rocm5.7/torch/ --no-dependencies
popd

engine="shark"
while read model batch sequence precision
do
    file="${model}-b${batch}-s${sequence}-${precision}"    
    tag="${file}-${engine}"
    options="-g -o no_opt -e shark"
    echo "*** python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
    /usr/bin/time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-shark-summary.csv --detail_csv $testdir/${file}-shark-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    sort -ru ${testdir}/${file}-shark-detail.csv > ${testdir}/${file}-detail-sort.csv
    sort -ru ${testdir}/${file}-shark-summary.csv > ${testdir}/${file}-summary-sort.csv
    cat ${testdir}/${file}-shark-summary-sort.csv >> ${testdir}/shark-summary.csv
done <<EOF    
bert-base-uncased 1 128 fp16
bert-base-uncased 1 128 fp32
bert-base-cased 1 32 fp16
bert-base-cased 1 384 fp16
bert-base-cased 32 32 fp16
bert-base-cased 32 384 fp16
bert-large-uncased 1 32 fp16
bert-large-uncased 1 384 fp16
bert-large-uncased 32 32 fp16
bert-large-uncased 32 384 fp16
distilgpt2 1 32 fp16
distilgpt2 1 384 fp16
distilgpt2 32 32 fp16
distilgpt2 32 384 fp16
EOF

deactivate
exit 0

ENGINES=('onnxruntime' 'torch' 'torch2' 'torchscript' 'tensorflow')
PROVIDERS=('rocm' 'migraphx' 'cpu')

while read model batch sequence precision
do
    for engine in "${ENGINES[@]}"
    do
	file="${model}-b${batch}-s${sequence}-${precision}-${engine}"    
	case $engine in
	    "onnxruntime")
		for provider in "${PROVIDERS[@]}"
		do
		    tag="${file}-${provider}"
		    case $provider in
			"cpu")
			    options="-e onnxruntime --provider cpu"			    
			;;
			"migraphx")
			    options="-g -e onnxruntime --provider migraphx --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu"
			;;
			"rocm")
			    options="-g -e onnxruntime --provider rocm"
			;;
		    esac
		    echo "*** python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
		    time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
		    sort -ru ${testdir}/${file}-detail.csv > ${testdir}/${file}-detail-sort.csv
		    sort -ru ${testdir}/${file}-summary.csv > ${testdir}/${file}-summary-sort.csv
		    cat ${testdir}/${file}-summary-sort.csv >> ${testdir}/summary.csv
		done
		continue
		;;
	    "torch")
		tag="${file}-${engine}"
		options="-o no_opt -e torch"		
		;;
	    "torch2")
		tag="${file}-${engine}"
		options="-o no_opt -e torch2"		
		;;
	    "torchscript")
		tag="${file}-${engine}"
		options="-o no_opt -e torchscript"		
		;;
	    "tensorflow")
		tag="${file}-${engine}"
		options="-o no_opt -e tensorflow"		
		;;
	    "shark")
		tag="${file}-${engine}"
		options="-o no_opt -e shark"
		;;    
	esac
	echo "*** python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
	time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
	sort -ru ${testdir}/${file}-detail.csv > ${testdir}/${file}-detail-sort.csv
	sort -ru ${testdir}/${file}-summary.csv > ${testdir}/${file}-summary-sort.csv
	cat ${testdir}/${file}-summary-sort.csv >> ${testdir}/summary.csv
    done
done <<EOF    
bert-base-uncased 1 128 fp16
bert-base-uncased 1 128 fp32
EOF

exit 0
#**************************************************************************************************************************************************************************
# Unused...
#**************************************************************************************************************************************************************************
# Ideal batch: 1,2,4,8,16,32,64,128,256
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-base-cased migraphx\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased migraphx\n" >> $testdir/dashboard.err
time python3 benchmark2.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32,64,128
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.err
time python3 benchmark2.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 32 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# Ideal batch: 1,2,4,8,16,32
# Ideal sequence: 16,32,64,128,256,384,512
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.err
time python3 benchmark2.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=migraphx -p fp16 --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

# clear the cached optimized models
rm ./onnx_models/*gpu*

echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased rocm\n" >> $testdir/dashboard.err
time python3 benchmark2.py -g -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** bert-large-uncased rocm\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased rocm\n" >> $testdir/dashboard.err
time python3 benchmark2.py -g -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 32 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** distilgpt2 rocm\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 rocm\n" >> $testdir/dashboard.err
time python3 benchmark2.py -g -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=rocm -p fp16 --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

while read model batch sequence precision
do
    file="${model}-b${batch}-s${sequence}-${precision}"
    tag="${model}-b${batch}-s${sequence}-${precision}-rocm"
    time python3 benchmark2.py -g -b $batch -m $model --sequence_length $sequence --precision $precision --provider rocm --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    tag="${model}-b${batch}-s${sequence}-${precision}-migraphx"
    time python3 benchmark2.py -o no_opt -g -b $batch -m $model --sequence_length $sequence --precision $precision --provider migraphx --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    if [ "$precision" = "fp32" ]; then
	tag="${model}-b${batch}-s${sequence}-${precision}-torch"	
	time python3 benchmark2.py -o no_opt -b $batch -m $model --sequence_length $sequence --precision $precision -e torch --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
	tag="${model}-b${batch}-s${sequence}-${precision}-torch2"	
	time python3 benchmark2.py -o no_opt -b $batch -m $model --sequence_length $sequence --precision $precision -e torch2 --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err	
	tag="${model}-b${batch}-s${sequence}-${precision}-torchscript"	
	time python3 benchmark2.py -o no_opt -b $batch -m $model --sequence_length $sequence --precision $precision -e torchscript --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
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
exit 1
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
