#!/bin/bash
export TF_ROCM_FUSION_ENABLE=1
RUN_MIGX=${RUN_MIGX:="1"}
SAVED_MODELS=${SAVED_MODELS:="../../saved-models"}
TEST_RESULTDIR=${TEST_RESULTDIR:="../test-results"}
MIGRAPHX=${MIGRAPHX:="/src/AMDMIGraphX"}
SCRIPTS=${SCRIPTS:="../../scripts"}
IMAGE=${IMAGE:="../../datasets/imagenet/ILSVRC2012_val_00000001.JPEG"}

export PYTHONPATH="${MIGRAPHX}/build/lib:${MIGRAPHX}/build/src/py"
# run predefined list of test files, all these relative to SAVED_MODELS dir
cd ${TEST_RESULTDIR}
testdir=bench-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir
cd $testdir

echo "resnet50v2"
if [ "$RUN_MIGX" = "1" ]; then
    /usr/bin/python ${SCRIPTS}/bench.py --model resnet50v2 --batch 1 --framework migraphx --save_file ${SAVED_MODELS}/slim/resnet50v2_i1.pb --image_file ${IMAGE} 1>resnet50v2i1_migx.out 2> resnet50v2i1_migx.err
    /usr/bin/python ${SCRIPTS}/bench.py --model resnet50v2 --batch 64 --framework migraphx --save_file ${SAVED_MODELS}/slim/resnet50v2_i64.pb --image_file ${IMAGE} 1>resnet50v2i64_migx.out 2> resnet50v2i64_migx.err
fi

/usr/bin/python3 ${SCRIPTS}/bench.py --model resnet50v2 --batch 1 --framework tensorflow --save_file ${SAVED_MODELS}/slim/resnet50v2_i1.pb --image_file ${IMAGE} 1>resnet50v2i1_tf.out 2> resnet50v2i1_tf.err
/usr/bin/python3 ${SCRIPTS}/bench.py --model resnet50v2 --batch 64 --framework tensorflow --save_file ${SAVED_MODELS}/slim/resnet50v2_i64.pb --image_file ${IMAGE} 1>resnet50v2i64_tf.out 2> resnet50v2i64_tf.err

echo "mobilenet"
if [ "$RUN_MIGX" = "1" ]; then
    /usr/bin/python ${SCRIPTS}/bench.py --model mobilenet --batch 1 --framework migraphx --save_file ${SAVED_MODELS}/slim/mobilenet_i1.pb --image_file ${IMAGE} 1>mobileneti1_migx.out 2> mobileneti64_migx.err
    /usr/bin/python ${SCRIPTS}/bench.py --model mobilenet --batch 64 --framework migraphx --save_file ${SAVED_MODELS}/slim/mobilenet_i64.pb --image_file ${IMAGE} 1>mobileneti64_migx.out 2> mobileneti64_migx.err
fi

/usr/bin/python3 ${SCRIPTS}/bench.py --model mobilenet --batch 1 --framework tensorflow --save_file ${SAVED_MODELS}/slim/mobilenet_i1.pb --image_file ${IMAGE} 1>mobileneti1_tf.out 2> mobileneti64_tf.err
/usr/bin/python3 ${SCRIPTS}/bench.py --model mobilenet --batch 64 --framework tensorflow --save_file ${SAVED_MODELS}/slim/mobilenet_i64.pb --image_file ${IMAGE} 1>mobileneti64_tf.out 2> mobileneti64_tf.err

echo "inception"
if [ "$RUN_MIGX" = "1" ]; then
    /usr/bin/python ${SCRIPTS}/bench.py --model inceptionv3 --resize_val 299 --batch 1 --framework migraphx --save_file ${SAVED_MODELS}/slim/inceptionv3_i1.pb --image_file ${IMAGE} 1>inceptionv3i1_migx.out 2> inceptionv3i1_migx.err
    /usr/bin/python ${SCRIPTS}/bench.py --model inceptionv3 --resize_val 299 --batch 32 --framework migraphx --save_file ${SAVED_MODELS}/slim/inceptionv3_i32.pb --image_file ${IMAGE} 1>inceptionv3i32_migx.out 2> inceptionv3i32_migx.err
fi

/usr/bin/python3 ${SCRIPTS}/bench.py --model inceptionv3 --resize_val 299 --batch 1 --framework tensorflow --save_file ${SAVED_MODELS}/slim/inceptionv3_i1.pb --image_file ${IMAGE} 1>inceptionv3i1_tf.out 2> inceptionv3i1_tf.err
/usr/bin/python3 ${SCRIPTS}/bench.py --model inceptionv3 --resize_val 299 --batch 32 --framework tensorflow --save_file ${SAVED_MODELS}/slim/inceptionv3_i32.pb --image_file ${IMAGE} 1>inceptionv3i32_tf.out 2> inceptionv3i32_tf.err
