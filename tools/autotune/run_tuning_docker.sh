#!/bin/bash
DOCKERIMAGE=${DOCKERIMAGE:="rocm-tuning:latest"}
TUNING_FILE=${TUNING_FILE:="convolutions.log"}
TUNING_TEMPLATE=${TUNING_TEMPLATE:="tuning_template.sh"}

TMPDIR=`mktemp -d /tmp/tuning.XXXX`
cp $TUNING_FILE $TMPDIR

# create template script for running tuning
sed -e "s?WORKDIR?$TMPDIR?g" -e "s?CONVOLUTIONS?$TUNING_FILE?g" $TUNING_TEMPLATE > $TMPDIR/runtune.sh
chmod 755 $TMPDIR/runtune.sh

docker run --device=/dev/kfd --device=/dev/dri --network=host --group-add=video -v $TMPDIR:$TMPDIR -v /home/mev:/home/mev -e HOSTDIR=$TMPDIR ${DOCKERIMAGE} $TMPDIR/runtune.sh

printf "results are in $TMPDIR\n"
