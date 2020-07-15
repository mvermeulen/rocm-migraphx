#!/bin/bash
#
# Run an individual ONNX runtime test case
# NOTE: Expects to run inside container build with ROCm.

if [ ! -f /usr/bin/time ]; then
    echo "Expects /usr/bin/time to be installed"
fi

TESTCASE=${TESTCASE:="opset11/tf_resnet_v2_50"}
ITERATIONS=${ITERATIONS:="1001"}
ONNXMODELDIR=${ONNXMODELDIR:="/home/mev/source/rocm-migraphx/saved-models/onnxruntime"}
ONNXRUNNER=${ONNXRUNNER:="/code/onnxruntime/build/Linux/Release/onnx_test_runner"}
EXPROVIDER=${EXPROVIDER:="migraphx"}
RUNCPU=${RUNCPU:="no"}

base=`basename $TESTCASE`

/usr/bin/time -p -o $base.time1 $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out1 2>$base.err1
/usr/bin/time -p -o $base.time${ITERATIONS}  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out${ITERATIONS} 2>$base.err${ITERATIONS}
migraphxtime1=`grep real ${base}.time1|awk '{print $2}'`
migraphxtimen=`grep real ${base}.time${ITERATIONS}|awk '{print $2}'`
cputime1=
cputimen=

base_cpu=${base}_cpu
if [ "$RUNCPU" != "no" ]; then
    /usr/bin/time -p -o $base_cpu.time1 $ONNXRUNNER -v -c 1 -r 1 -e cpu $ONNXMODELDIR/$TESTCASE 1>$base_cpu.out1 2>$base_cpu.err1
    /usr/bin/time -p -o $base_cpu.time${ITERATIONS}  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e cpu $ONNXMODELDIR/$TESTCASE 1>$base_cpu.out${ITERATIONS} 2>$base_cpu.err${ITERATIONS}
    cputime1=`grep real ${base}_cpu.time1|awk '{print $2}'`
    cputimen=`grep real ${base}_cpu.time${ITERATIONS}|awk '{print $2}'`    
fi

echo $base,`echo $migraphxtimen-$migraphxtime1|bc`,$ITERATIONS,$migraphxtime1,$migraphxtimen,$cputime1,$cputimen > ${base}.sum

