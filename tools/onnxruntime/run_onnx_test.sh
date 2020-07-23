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
PREFIX=${PREFIX:=""}

base=`basename $TESTCASE`

# first run may cause kernels to be compiled
env MIOPEN_ENABLE_LOGGING_CMD=1 MIGRAPHX_TRACE_EVAL=1 /usr/bin/time -p -o ${PREFIX}${base}.time1x $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out1x 2>${PREFIX}${base}.err1x
# three runs for real
/usr/bin/time -p -o ${PREFIX}${base}.time1a $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out1a 2>${PREFIX}${base}.err1a
/usr/bin/time -p -o ${PREFIX}${base}.time${ITERATIONS}a  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out${ITERATIONS}a 2>${PREFIX}${base}.err${ITERATIONS}a
/usr/bin/time -p -o ${PREFIX}${base}.time1b $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out1b 2>${PREFIX}${base}.err1b
/usr/bin/time -p -o ${PREFIX}${base}.time${ITERATIONS}b  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out${ITERATIONS}b 2>${PREFIX}${base}.err${ITERATIONS}b
/usr/bin/time -p -o ${PREFIX}${base}.time1c $ONNXRUNNER -v -c 1 -r 1 -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out1c 2>${PREFIX}${base}.err1c
/usr/bin/time -p -o ${PREFIX}${base}.time${ITERATIONS}c  $ONNXRUNNER -v -c 1 -r ${ITERATIONS} -e ${EXPROVIDER} $ONNXMODELDIR/$TESTCASE 1>${PREFIX}${base}.out${ITERATIONS}c 2>${PREFIX}${base}.err${ITERATIONS}c

migraphxtime1a=`grep real ${PREFIX}${base}.time1a|awk '{print $2}'`
migraphxtimena=`grep real ${PREFIX}${base}.time${ITERATIONS}a|awk '{print $2}'`
migraphxtime1b=`grep real ${PREFIX}${base}.time1b|awk '{print $2}'`
migraphxtimenb=`grep real ${PREFIX}${base}.time${ITERATIONS}b|awk '{print $2}'`
migraphxtime1c=`grep real ${PREFIX}${base}.time1c|awk '{print $2}'`
migraphxtimenc=`grep real ${PREFIX}${base}.time${ITERATIONS}c|awk '{print $2}'`

echo -e `echo $migraphxtimena-$migraphxtime1a|bc` '\n' \
     `echo $migraphxtimenb-$migraphxtime1b|bc` '\n' \
     `echo $migraphxtimenc-$migraphxtime1c|bc` | calc-median > ${PREFIX}${base}.timen
migraphxtimen=`cat ${PREFIX}${base}.timen`

echo ${PREFIX}${base},`echo $migraphxtimena-$migraphxtime1a|bc`,$ITERATIONS,$migraphxtime1a,$migraphxtimena > ${PREFIX}${base}.suma
echo ${PREFIX}${base},`echo $migraphxtimenb-$migraphxtime1b|bc`,$ITERATIONS,$migraphxtime1b,$migraphxtimenb > ${PREFIX}${base}.sumb
echo ${PREFIX}${base},`echo $migraphxtimenc-$migraphxtime1c|bc`,$ITERATIONS,$migraphxtime1c,$migraphxtimenc > ${PREFIX}${base}.sumc
echo ${PREFIX}${base},$migraphxtimen,$ITERATIONS > ${PREFIX}${base}.sum
