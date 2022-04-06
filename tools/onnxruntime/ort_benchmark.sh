#!/bin/bash
set -x
TEST_RESULTDIR=${TEST_RESULTDIR:="/home/mev/source/rocm-migraphx/test-results"}
EXPROVIDER=${EXPROVIDER:="migraphx"}
EXEDIR=${EXEDIR:="/workspace/onnxruntime/onnxruntime/python/tools/transformers"}

testdir=${TEST_RESULTDIR}/onnxruntime-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
pushd $testdir
git log > $testdir/commit.txt
case $EXPROVIDER in
    cpu)
	cat /proc/cpuinfo > $testdir/cpu.txt
	GPUFLAG=""
	PRECISION="fp32"
	OPTFLAGS=""
	;;
    tensorrt)
	cat /proc/cpuinfo > $testdir/cpu.txt	
	nvidia-smi -q > $testdir/nvidia.txt
	GPUFLAG="-g"
	PRECISION="fp16"	
	OPTFLAGS=""
	;;
    cuda)
	cat /proc/cpuinfo > $testdir/cpu.txt	
	nvidia-smi -q > $testdir/nvidia.txt
	GPUFLAG="-g"
	PRECISION="fp16"	
	OPTFLAGS=""
	;;
    migraphx)
	cat /proc/cpuinfo > $testdir/cpu.txt	
	export TOKENIZERS_PARALLELISM=false
	rocminfo > $testdir/rocminfo.txt
	GPUFLAG="-g"	
	PRECISION="fp16"
	OPTFLAGS="--disable_gelu --disable_layer_norm --disable_attention --disable_skip_layer_norm --disable_embed_layer_norm --disable_bias_skip_layer_norm --disable_bias_gelu"
	;;
    rocm)
	cat /proc/cpuinfo >  $testdir/cpu.txt	
	rocminfo > $testdir/rocminfo.txt
	GPUFLAG="-g"	
	PRECISION="fp16"	
	OPTFLAGS=""
	;;
esac
popd
cd ${EXEDIR}
touch ${testdir}/summary.csv

echo "\n***** bert-base-cased ${EXPROVIDER}\n" >> $testdir/dashboard.out
echo "\n***** bert-base-cased ${EXPROVIDER}\n" >> $testdir/dashboard.err
python benchmark.py $GPUFLAG -m bert-base-cased --sequence_length 32 384 --batch_sizes 1 32 --provider=${EXPROVIDER} -p ${PRECISION} ${OPTFLAGS} --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.out
echo "\n***** bert-large-uncased migraphx\n" >> $testdir/dashboard.err
python benchmark.py $GPUFLAG -m bert-large-uncased --sequence_length 32 384 --batch_sizes 1 32 --provider=${EXPROVIDER} -p ${PRECISION} ${OPTFLAGS} --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.out
echo "\n***** distilgpt2 migraphx\n" >> $testdir/dashboard.err
python benchmark.py $GPUFLAG -m distilgpt2 --model_class AutoModelForCausalLM --sequence_length 32 384 --batch_sizes 1 8 --provider=${EXPROVIDER} -p ${PRECISION} ${OPTFLAGS} --result_csv $testdir/dashboard.csv --detail_csv $testdir/dashboard-detail.csv 1>>$testdir/dashboard.out 2>>$testdir/dashboard.err

cp $testdir/dashboard.csv $testdir/${EXPROVIDER}.csv
