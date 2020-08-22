#!/bin/bash
for f in *unique.sh
do
    base=`basename $f .sh`
    bash $f > ${base}.out 2> ${base}.err
    rm $f
done
