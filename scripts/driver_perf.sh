#!/bin/bash
#
# Report performance statistics from MIOpen convolutions using driver perf
#
export DRIVER=${DRIVER:=/src/AMDMIGraphX/build/bin/driver}

# file descriptor #1 is list of cmds
miopen_cmds=$(mktemp /tmp/driver_perf_miopen_cmds.XXXXXX)
miopen_conv=$(mktemp /tmp/driver_perf_miopen_conv.XXXXXX)
miopen_run=$(mktemp /tmp/driver_perf_miopen_run.XXXXXX)
miopen_stat=$(mktemp /tmp/driver_perf_miopen_stat.XXXXXX)

if [ $# != 1 ]; then
    echo usage: $0 "<onnx file>"
    exit 0
fi

outfile=`basename $1 .onnx`.csv
set -x
env MIOPEN_ENABLE_LOGGING_CMD=1 ${DRIVER} run $1 1> $miopen_run 2> $miopen_cmds
grep LogCmdConvolution $miopen_cmds | awk '{ $1=$2=$3=""; print $0 }' | sed 's/^ *//g' | uniq > $miopen_conv
cat $miopen_conv | while read cmdline
do
    /opt/rocm/miopen/$cmdline | grep ^stats >> $miopen_stat
done
sort -u -r $miopen_stat > $outfile
cat $outfile

rm $miopen_cmds $miopen_conv $miopen_run $miopen_stat
