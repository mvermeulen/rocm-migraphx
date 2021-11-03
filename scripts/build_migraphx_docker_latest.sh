#!/bin/bash
set -x
DATESTAMP=`date '+%Y%m%d'`
BUILD_NAVI=${BUILD_NAVI:="0"}

if [ "$BUILD_NAVI" = "0" ]; then
    BASE=${BASE:="rocm-migraphx:4.5"}
else
    BASE=${BASE:="rocm-migraphx:4.5n"}
fi

MIOPENTUNE=${MIOPENTUNE:="miopen-rocm45"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd ../dockerfiles
if [ "$BUILD_NAVI" = "0" ]; then
    docker build -t rocm-migraphx:${DATESTAMP} --no-cache --build-arg DOCKERBASE=${BASE} --build-arg MIOPENTUNE=${MIOPENTUNE} -f ../dockerfiles/dockerfile-daily .
else
    docker build -t rocm-migraphx:${DATESTAMP}n --no-cache --build-arg DOCKERBASE=${BASE} --build-arg MIOPENTUNE=${MIOPENTUNE} -f ../dockerfiles/dockerfile-daily .
fi

