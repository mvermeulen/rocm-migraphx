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

base=`basename $TESTCASE`

/usr/bin/time -o $base.time1 $ONNXRUNNER -c 1 -r 1 -e migraphx $ONNXMODELDIR/$TESTCASE 1>$base.out1 2>$base.err1
/usr/bin/time -o $base.time${ITERATIONS}  $ONNXRUNNER -c 1 -r ${ITERATIONS} -e migraphx $ONNXMODELDIR/$TESTCASE 1>$base.out${ITERATIONS} 2>$base.err${ITERATIONS}
