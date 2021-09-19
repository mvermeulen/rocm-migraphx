#!/bin/bash
# BERT MRPC test
set -x

MIGX=${MIGX:="/src/rocm-migraphx/tools/migx/build/migx"}
TEST_RESULTDIR=${TEST_RESULTDIR:="/src/test-results"}
MODELDIR=${MODELDIR:="/src/saved-models"}
GLUEDIR=${GLUEDIR:="/src/glue"}

testdir=${TEST_RESULTDIR}/bertmrpc-`date '+%Y-%m-%d-%H-%M'`
mkdir $testdir

${MIGX} --glue=MRPC --gluefile=${GLUEDIR}/MRPC.tst --tfpb ${MODELDIR}/bert_mrpc1.pb 2>${testdir}/bertmrpc-fp32.err | tee ${testdir}/bertmrpc-fp32.out
${MIGX} --glue=MRPC --gluefile=${GLUEDIR}/MRPC.tst --tfpb ${MODELDIR}/bert_mrpc1.pb --fp16 2>${testdir}/bertmrpc-fp16.err | tee ${testdir}/bertmrpc-fp16.out
