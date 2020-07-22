#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "usage: check_tuning.sh <filename>"
fi
MIOPEN_TUNE=${MIOPEN_TUNE:="./miopen_tune"}
cat $1 | grep MIOpenDriver | sed -e 's/^.*MIOpenDriver //g' | sort -u | while read oper line
do
    if [ $oper != "conv" -a $oper != "convfp16" ]; then
	continue
    fi

#    echo $MIOPEN_TUNE check $oper $line
    $MIOPEN_TUNE check $oper $line > out 2>err
    result=$?
    if [ $result = "0" ]; then
	echo "Not found: $line"
    else
	echo "Found    : $line"
    fi
done

