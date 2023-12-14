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
    /usr/bin/time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-${engine}-summary.csv --detail_csv $testdir/${file}-${engine}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err

    sort -ru ${testdir}/${file}-${engine}-detail.csv > ${testdir}/${file}-${engine}-detail-sort.csv
    sort -ru ${testdir}/${file}-${engine}-summary.csv > ${testdir}/${file}-${engine}-summary-sort.csv
    cat ${testdir}/${file}-${engine}-summary-sort.csv >> ${testdir}/${engine}-summary.csv
done <<EOF    
bert-base-uncased 1 128 fp16
bert-base-uncased 1 128 fp32
EOF

engine="torchscript"
while read model batch sequence precision
do
    file="${model}-b${batch}-s${sequence}-${precision}"    
    tag="${file}-${engine}"
    options="-g -o no_opt -e torchscript"
    echo "*** python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
    /usr/bin/time -o $testdir/${tag}.time python3 benchmark2.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-${engine}-summary.csv --detail_csv $testdir/${file}-${engine}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err

    sort -ru ${testdir}/${file}-${engine}-detail.csv > ${testdir}/${file}-${engine}-detail-sort.csv
    sort -ru ${testdir}/${file}-${engine}-summary.csv > ${testdir}/${file}-${engine}-summary-sort.csv
    cat ${testdir}/${file}-${engine}-summary-sort.csv >> ${testdir}/${engine}-summary.csv
done <<EOF    
bert-base-uncased 1 128 fp16
bert-base-uncased 1 128 fp32
EOF

deactivate
exit 0

ENGINES=('torchscript')
#ENGINES=('onnxruntime' 'torch' 'torch2' 'torchscript' 'tensorflow')
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
exit 0
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

    /usr/bin/time -o $testdir/${tag}.time python3 benchmark2.py -g -o no_opt -e torchscript -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-shark-summary.csv --detail_csv $testdir/${file}-shark-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err    
    sort -ru ${testdir}/${file}-shark-detail.csv > ${testdir}/${file}-shark-detail-sort.csv
    sort -ru ${testdir}/${file}-shark-summary.csv > ${testdir}/${file}-shark-summary-sort.csv
    cat ${testdir}/${file}-shark-summary-sort.csv >> ${testdir}/shark-summary.csv
done <<EOF    
bert-base-uncased 1 128 fp16
bert-base-uncased 1 128 fp32
EOF

deactivate
exit 0

