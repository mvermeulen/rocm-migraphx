#!/bin/bash
export MIOPEN_FIND_ENFORCE=3
export MIOPEN_FIND_MODE=1
MIOPENDIR=/root/.config/miopen
count=0
for f in *unique.sh
do
    count=$((count+1))
    base=`basename $f .sh`
    bash $f > ${base}.out 2> ${base}.err
    cp -r ${MIOPENDIR} /home/mev/miopen-${count}
    echo ------
    date
    echo $f
    mv $f /home/mev/miopen-${count}
done
