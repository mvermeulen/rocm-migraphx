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

ENGINES=('onnxruntime' 'shark' 'torch' 'torch2' 'torchscript' 'tensorflow')
PROVIDERS=('rocm' 'migraphx' 'cpu')

while read model batch sequence precision
do
    file="${model}-b${batch}-s${sequence}-${precision}"    
    for engine in "${ENGINES[@]}"
    do
	case $engine in
	    "onnxruntime")
		for provider in "${PROVIDERS[@]}"
		do
		    tag="${file}-${engine}-${provider}"
		    case $provider in
			"cpu")
			    if [ "$precision" = "fp16" ]; then
				continue
			    fi
			    options="-e onnxruntime --provider cpu"
			;;
			"migraphx")
			    options="-g -e onnxruntime --provider migraphx --disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu"
			;;
			"rocm")
			    options="-g -e onnxruntime --provider rocm"
			;;
		    esac
		    echo "*** python3 benchmark.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
		    /usr/bin/time -o ${testdir}/${tag}.time python3 benchmark.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
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
	echo "*** python3 benchmark.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision"
	/usr/bin/time -o $testdir/${tag}.time python3 benchmark.py ${options} -m $model --batch_sizes $batch --sequence_length $sequence -p $precision --result_csv $testdir/${file}-summary.csv --detail_csv $testdir/${file}-detail.csv 1>$testdir/${tag}.out 2>$testdir/${tag}.err
    done
    sort -ru ${testdir}/${file}-detail.csv > ${testdir}/${file}-detail-sort.csv
    sort -ru ${testdir}/${file}-summary.csv > ${testdir}/${file}-summary-sort.csv
    cat ${testdir}/${file}-summary-sort.csv >> ${testdir}/summary.csv
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
# Previous models of interest
#bert-base-cased 1 32 fp16
#bert-base-cased 1 384 fp16
#bert-base-cased 32 32 fp16
#bert-base-cased 32 384 fp16
#bert-large-uncased 1 32 fp16
#bert-large-uncased 1 384 fp16
#bert-large-uncased 32 32 fp16
#bert-large-uncased 32 384 fp16
#distilgpt2 1 32 fp16
#distilgpt2 1 384 fp16
#distilgpt2 32 32 fp16
#distilgpt2 32 384 fp16

