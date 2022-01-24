#!/bin/bash
MIOPEN_USER_DB=/root/.config/miopen

cd WORKDIR

export VERBOSE=0

printf "Running tuning docker to create MIGraphX tuned db\n" | tee manifest.txt
printf "\tWorking directory\tWORKDIR\n"                      | tee -a manifest.txt
printf "\tONNX file\tONNX_FILE\n"                            | tee -a manifest.txt
printf "\tFUSION setting\tFUSION_SETTING\n"                  | tee -a manifest.txt

if [ -d $MIOPEN_USER_DB ]; then
    printf "$MIOPEN_USER_DB is present, saving away\n"       | tee -a manifest.txt
    mv $MIOPEN_USER_DB WORKDIR/miopen.orig
fi

echo "Dumping database entries"
count=0
cat CONVOLUTIONS | sed -e 's?./bin/MIOpenDriver conv?./lookup_db?g' | while read line
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

echo "Running before tuning"
/src/AMDMIGraphX/build/bin/driver perf ONNX_FILE 1>pretune.perf_report.out 2>pretune.perf_report.err

echo "Tuning without fusions"
echo "Tuning started" | tee -a manifest.txt
date '+%s'            | tee -a manifest.txt
env MIOPEN_FIND_ENFORCE=4 FUSION_SETTING /src/AMDMIGraphX/build/bin/driver perf ONNX_FILE 1>tune.perf_report.out 2>tune.perf_report.err
echo "Tuning finished" | tee -a manifest.txt
date '+%s'             | tee -a manifest.txt

echo "Dumping database entries"
count = 0
cat CONVOLUTIONS | sed -e 's?./bin/MIOpenDriver conv?./lookup_db?g' | while read line
do
    count=$(( count + 1 ))
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

echo "Running after tuning"
/src/AMDMIGraphX/build/bin/driver perf ONNX_FILE 1>posttune.perf_report.out 2>posttune.perf_report.err

pushd $MIOPEN_USER_DB
/root/dumpdb.sh *.udb
popd

mv $MIOPEN_USER_DB WORKDIR/miopen
