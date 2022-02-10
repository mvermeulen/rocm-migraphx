#!/bin/bash
set -x
DATESTAMP=`date '+%Y%m%d'`
BUILD_NAVI=${BUILD_NAVI:="0"}
BRANCH=${BRANCH:="develop"}
DOCKERIMAGE=${DOCKERIMAGE:="rocm-migraphx:$DATESTAMP"}

if [ "$BUILD_NAVI" = "0" ]; then
    BASE=${BASE:="rocm-migraphx:5.0"}
else
    BASE=${BASE:="rocm-migraphx:5.0n"}
fi

MIOPENTUNE=${MIOPENTUNE:="miopen-rocm50"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd ../dockerfiles
if [ "$BUILD_NAVI" = "0" ]; then
    docker build -t ${DOCKERIMAGE} --no-cache --build-arg BRANCH=${BRANCH} --build-arg DOCKERBASE=${BASE} --build-arg MIOPENTUNE=${MIOPENTUNE} -f ../dockerfiles/dockerfile-daily .
else
    docker build -t $DOCKERIMAGE}n --no-cache --build-arg BRANCH=${BRANCH} --build-arg DOCKERBASE=${BASE} --build-arg MIOPENTUNE=${MIOPENTUNE} -f ../dockerfiles/dockerfile-daily .
fi

