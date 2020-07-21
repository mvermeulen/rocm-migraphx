#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "usage: check_tuning.sh <filename>"
fi
MIOPEN_TUNE=${MIOPEN_TUNE:="./miopen_tune"}
cat $1 | grep MIOpenDriver | sed -e 's/^.*MIOpenDriver //g' | while read line
do
    $MIOPEN_TUNE check $line
done

