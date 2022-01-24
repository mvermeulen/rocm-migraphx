#!/bin/bash
MIOPEN_USER_DB=$HOME/.config/miopen

cd WORKDIR

lines=`wc -l CONVOLUTIONS`

export MIOPEN_FIND_MODE=1
export MIOPEN_LOG_LEVEL=5
export VERBOSE=0

printf "Running tuning docker to create MIOpen db\n"  | tee manifest.txt
printf "\tWorking directory\tWORKDIR\n"               | tee -a manifest.txt
printf "\tInput file       \tCONVOLUTIONS\n"          | tee -a manifest.txt
printf "\tNumber of convolutions to tune: $lines\n"   | tee -a manifest.txt

if [ -d $MIOPEN_USER_DB ]; then
    printf "$MIOPEN_USER_DB is present\n"             | tee -a manifest.txt
    ls -l $MIOPEN_USER_DB                             | tee -a manifest.txt
else
    printf "$MIOPEN_USER_DB is not present\n"         | tee -a manifest.txt
    
fi

echo "Dumping database entries"
count=0
cat CONVOLUTIONS | sed -e 's?./bin/MIOpenDriver conv?/root/lookup_db?g' | while read line
do
    count=$(( count + 1 ))
    env LABEL="conv ${count}: " $line /opt/rocm/miopen/share/miopen/db/gfx906*.db /root/.config/miopen/*.udb
done 2>&1 | tee WORKDIR/pretune.db.log

echo "Measuring before tuning"
cat CONVOLUTIONS | sed -e 's?-S 0?-S -1?g' | while read line
do
    pushd /opt/rocm/miopen
    $line
    popd
done 2>WORKDIR/pretune.err | tee WORKDIR/pretune.log

echo "Performing tuning"
export MIOPEN_FIND_ENFORCE=4
echo "Tuning started" | tee -a manifest.txt
date '+%s' | tee -a manifest.txt
cat CONVOLUTIONS | sed -e 's?-S 0?-S -1?g' | while read line
do
    pushd /opt/rocm/miopen
    $line -s 1
    popd
done 2>WORKDIR/tune.err | tee WORKDIR/tune.log
echo "Tuning finished" | tee -a manifest.txt
date '+%s' | tee -a manifest.txt

echo "Dumping database entries"
count=0
cat CONVOLUTIONS | sed -e 's?./bin/MIOpenDriver conv?/root/lookup_db?g' | while read line
do
    count=$(( count + 1))
    env LABEL="conv ${count}: " $line /opt/rocm/miopen/share/miopen/db/gfx906*.db /root/.config/miopen/*.udb
done 2>&1 | tee WORKDIR/posttune.db.log

echo "Measuring after tuning"
unset MIOPEN_FIND_ENFORCE
cat CONVOLUTIONS | sed -e 's?-S 0?-S -1?g' | while read line
do
    pushd /opt/rocm/miopen
    $line
    popd
done 2>WORKDIR/posttune.err | tee WORKDIR/posttune.log

fgrep stats pretune.log  | sort -r -u | awk '{ $1=""; print $0 }' > pretune.csv
fgrep stats posttune.log | sort -r -u | awk '{ $1=""; print $0 }' > posttune.csv

cd $MIOPEN_USER_DB
/root/dumpdb.sh *.udb

cp -r $MIOPEN_USER_DB WORKDIR
