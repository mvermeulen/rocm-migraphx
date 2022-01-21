#!/bin/bash
MIOPEN_USER_DB=$HOME/.config/miopen

cd WORKDIR

lines=`wc -l CONVOLUTIONS`

printf "Running tuning docker to create MIOpen db\n"
printf "\tWorking directory\tWORKDIR\n"
printf "\tInput file       \tCONVOLUTIONS\n"
printf "\tNumber of convolutions to tune: $lines\n"

if [ -d $MIOPEN_USER_DB ]; then
    printf "$MIOPEN_USER_DB is present\n"
    ls -l $MIOPEN_USER_DB
else
    printf "$MIOPEN_USER_DB is not present\n"
    
fi

echo "Measuring before tuning"
cat CONVOLUTIONS | sed -e 's?-S 0?-S -1?g' | while read line
do
    pushd /opt/rocm/miopen
    $line
    popd
done 2>&1 | tee WORKDIR/pretune.log

echo "Performing tuning"
export MIOPEN_FIND_ENFORCE=4
cat CONVOLUTIONS | sed -e 's?-S 0?-S -1?g' | while read line
do
    pushd /opt/rocm/miopen
    $line -s 1
    popd
done 2>&1 | tee WORKDIR/tune.log

echo "Measuring after tuning"
unset MIOPEN_FIND_ENFORCE
cat CONVOLUTIONS | sed -e 's?-S 0?-S -1?g' | while read line
do
    pushd /opt/rocm/miopen
    $line
    popd
done 2>&1 | tee WORKDIR/posttune.log

fgrep stats pretune.log  | sort -r -u | awk '{ $1=""; print $0 }' > pretune.csv
fgrep stats posttune.log | sort -r -u | awk '{ $1=""; print $0 }' > posttune.csv

cd $MIOPEN_USER_DB
/root/dumpdb.sh *.udb

cp -r $MIOPEN_USER_DB WORKDIR
