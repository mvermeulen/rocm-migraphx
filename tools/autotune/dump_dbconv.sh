#!/bin/bash
#
# Take a database and dump relevant convolutions from list
#
TUNING_FILE=${TUNING_FILE:="/home/mev/source/rocm-migraphx/tools/autotune/resnet50/resnet50_nofusion.conv"}
LOOKUP_DB=${LOOKUP_DB:="/home/mev/source/rocm-migraphx/tools/autotune/lookup_db"}

export VERBOSE=0

count=0
cat $TUNING_FILE | sed -e "s?./bin/MIOpenDriver conv?$LOOKUP_DB?g" | while read line
do
    count=$(( count + 1 ))
    env LABEL="conv ${count}: " $line $1
done

