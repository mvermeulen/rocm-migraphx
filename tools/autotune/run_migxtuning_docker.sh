#!/bin/bash
set -x
DOCKERIMAGE=${DOCKERIMAGE:="rocm-migraphx:5.0-rc2"}
ONNX_FILE=${ONNX_FILE:="/home/mev/source/rocm-migraphx/saved-models/torchvision/resnet50i1.onnx"}
MIGXTUNING_TEMPLATE=${MIGXTUNING_TEMPLATE:="migxtuning_template.sh"}
LOOKUP_DB=${LOOKUP_DB:="/home/mev/source/rocm-migraphx/tools/autotune/lookup_db"}
TUNING_FILE=${TUNING_FILE:="convolutions.log"}

TMPDIR=`mktemp -d /tmp/tuning.XXXX`
cp $TUNING_FILE $TMPDIR

# create template script for running tuning
sed -e "s?WORKDIR?$TMPDIR?g" -e "s?ONNX_FILE?$ONNX_FILE?g" -e "s?CONVOLUTIONS?$TUNING_FILE?g" $MIGXTUNING_TEMPLATE > $TMPDIR/runtune.sh
cp $LOOKUP_DB $TMPDIR/lookup_db
chmod 755 $TMPDIR/runtune.sh

docker run --device=/dev/kfd --device=/dev/dri --network=host --group-add=video -v $TMPDIR:$TMPDIR -v /home/mev:/home/mev -e HOSTDIR=$TMPDIR ${DOCKERIMAGE} $TMPDIR/runtune.sh

printf "results are in $TMPDIR\n"
