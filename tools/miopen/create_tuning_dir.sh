#!/bin/bash
#
# Take a performance results directory that includes MIOPEN_ENABLE_LOGGING_CMD, create tuning script files.
#
MIOPEN_DRIVER=${MIOPEN_DRIVER:="/opt/rocm/miopen/bin/MIOpenDriver"}
SUFFIX=".err"
OUTPUTDIR=${OUTPUTDIR:="results"}

if [ "$#" -ne 1 ]; then
    echo "usage: create_tuning_dir.sh <results-directory>"
    exit 0
fi

if [ ! -f ${MIOPEN_DRIVER} ]; then
    echo ${MIOPEN_DRIVER} not found
    exit 0
fi

if [ -d $OUTPUTDIR ]; then
    echo "$OUTPUTDIR exists, please remove"
    exit 0
else
    mkdir $OUTPUTDIR
    cd $OUTPUTDIR
fi


ls $1/*${SUFFIX} | while read file
do
    filebase=`basename $file $SUFFIX`
    cat $file | grep MIOpenDriver | sed -e 's/^.*MIOpenDriver //g' > ${filebase}.sh
done

