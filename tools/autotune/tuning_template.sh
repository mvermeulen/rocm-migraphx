#!/bin/bash
MIOPEN_USER_DB=$HOME/.config/miopen

cd WORKDIR

lines=`wc -l CONVOLUTIONS`

printf "Running tuning docker to create MIOpen db\n"
printf "\tWorking directory\tWORKDIR\n"
printf "\tNumber of convolutions to tune: $lines\n"

if [ -d $MIOPEN_USER_DB ]; then
    printf "$MIOPEN_USER_DB is present\n"
    ls -l $MIOPEN_USER_DB
else
    printf "$MIOPEN_USER_DB is not present\n"
    
fi

echo "Measuring before tuning"
cat CONVOLUTIONS | while read line
do
    echo $line
    pushd /opt/rocm/miopen
    $line
    popd
done 2>&1 | tee WORKDIR/pretune.log

echo "Performing tuning"
export MIOPEN_FIND_ENFORCE=4
cat CONVOLUTIONS | while read line
do
    echo $line
    pushd /opt/rocm/miopen
    $line -S -1
    popd
done 2>&1 | tee WORKDIR/tune.log

echo "Measuring after tuning"
export MIOPEN_FIND_ENFORCE=0
cat CONVOLUTIONS | while read line
do
    echo $line
    pushd /opt/rocm/miopen
    $line
    popd
done 2>&1 | tee WORKDIR/posttune.log

cp -r $MIOPEN_USER_DB WORKDIR
