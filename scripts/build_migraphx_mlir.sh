#!/bin/bash
MIGRAPHX_DIR=${MIGRAPHX_DIR:="/home/mev/source/AMDMIGraphX"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

DATESTAMP=`date '+%Y%m%d'`
cd $MIGRAPHX_DIR
docker build --no-cache -f Dockerfile -t migxmlir:${DATESTAMP} . 2>&1 | tee build.${DATESTAMP}



