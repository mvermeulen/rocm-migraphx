#!/bin/bash
export MIOPEN_FIND_ENFORCE=3
for f in *unique.sh
do
    base=`basename $f .sh`
    bash $f > ${base}.out 2> ${base}.err
    echo ------
    date
    echo $f
    rm $f
done
