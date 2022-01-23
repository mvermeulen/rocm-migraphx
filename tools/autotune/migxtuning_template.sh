#!/bin/bash
MIOPEN_USER_DB=/root/.config/miopen

cd WORKDIR

printf "Running tuning docker to create MIGraphX tuned db\n" | tee manifest.txt
printf "\tWorking directory\tWORKDIR\n"                      | tee -a manifest.txt
printf "\tONNX file\tONNX_FILE\n"                            | tee -a manifest.txt

if [ -d $MIOPEN_USER_DB ]; then
    printf "$MIOPEN_USER_DB is present, saving away\n"       | tee -a manifest.txt
    mv $MIOPEN_USER_DB WORKDIR/miopen.orig
fi

echo "Dumping database entries"
cat CONVOLUTIONS | sed -e 's?./bin/MIOpenDriver conv?./lookup_db?g' | while read line
do
    echo $line
    $line /opt/rocm/miopen/share/miopen/db/gfx906*.db /root/.config/miopen/*.udb
done 2>&1 | tee WORKDIR/pretune.db.log

echo "Running before tuning"
/src/AMDMIGraphX/build/bin/driver perf ONNX_FILE 1>pretune.perf_report.out 2>pretune.perf_report.err

echo "Tuning without fusions"
env MIOPEN_FIND_ENFORCE=4 MIGRAPHX_DISABLE_MIOPEN_FUSION=1 /src/AMDMIGraphX/build/bin/driver/perf ONNX_FILE 1>tune.perf_report.out 2>tune.perf_report.err

echo "Dumping database entries"
cat CONVOLUTIONS | sed -e 's?./bin/MIOpenDriver conv?./lookup_db?g' | while read line
do
    echo $line
    $line /opt/rocm/miopen/share/miopen/db/gfx906*.db /root/.config/miopen/*.udb
done 2>&1 | tee WORKDIR/posttune.db.log

echo "Running after tuning"
/src/AMDMIGraphX/build/bin/driver perf ONNX_FILE 1>pretune.perf_report.out 2>pretune.perf_report.err

pushd $MIOPEN_USER_DB
/root/dumpdb.sh *.udb
popd

cp -r $MIOPEN_USER_DB WORKDIR/miopen
