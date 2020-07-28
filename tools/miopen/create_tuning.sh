#!/bin/bash
#
# Take output created from MIOPEN_ENABLE_LOGGING_CMD=1 as a filename.
# Create stdout that reflects the commands needed to tune.
#
MIOPEN_DRIVER=${MIOPEN_DRIVER:="/opt/rocm/miopen/bin/MIOpenDriver"}

if [ "$#" -ne 1 ]; then
    echo "usage: create_tuning.sh <filename>"
    exit 0
fi
if [ ! -f ${MIOPEN_DRIVER} ]; then
    echo ${MIOPEN_DRIVER} not found
    exit 0
fi

cat $1 | grep MIOpenDriver | sed -e 's/^.*MIOpenDriver //g' | sort -u | while read oper line
do
    if [ $oper != "conv" -a $oper != "convfp16" ]; then
	continue
    fi
    echo ${MIOPEN_DRIVER} $oper $line
done

