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

base=`basename $TESTCASE`

# first run may cause kernels to be compiled
/usr/bin/time -p -o $base.time1x $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out1x 2>$base.err1x
# three runs for real
/usr/bin/time -p -o $base.time1a $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out1a 2>$base.err1a
/usr/bin/time -p -o $base.time${ITERATIONS}a  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out${ITERATIONS}a 2>$base.err${ITERATIONS}a
/usr/bin/time -p -o $base.time1b $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out1b 2>$base.err1b
/usr/bin/time -p -o $base.time${ITERATIONS}b  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out${ITERATIONS}b 2>$base.err${ITERATIONS}b
/usr/bin/time -p -o $base.time1c $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out1c 2>$base.err1c
/usr/bin/time -p -o $base.time${ITERATIONS}c  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>$base.out${ITERATIONS}c 2>$base.err${ITERATIONS}c

migraphxtime1a=`grep real ${base}.time1a|awk '{print $2}'`
migraphxtimena=`grep real ${base}.time${ITERATIONS}a|awk '{print $2}'`
migraphxtime1b=`grep real ${base}.time1b|awk '{print $2}'`
migraphxtimenb=`grep real ${base}.time${ITERATIONS}b|awk '{print $2}'`
migraphxtime1c=`grep real ${base}.time1c|awk '{print $2}'`
migraphxtimenc=`grep real ${base}.time${ITERATIONS}c|awk '{print $2}'`

echo $base,`echo $migraphxtimena-$migraphxtime1a|bc`,$ITERATIONS,$migraphxtime1a,$migraphxtimena > ${base}.suma
echo $base,`echo $migraphxtimenb-$migraphxtime1b|bc`,$ITERATIONS,$migraphxtime1b,$migraphxtimenb > ${base}.sumb
echo $base,`echo $migraphxtimenc-$migraphxtime1c|bc`,$ITERATIONS,$migraphxtime1c,$migraphxtimenc > ${base}.sumc

