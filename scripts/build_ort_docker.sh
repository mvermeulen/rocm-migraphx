#!/bin/bash
set -x
DOCKERFILE=${DOCKERFILE:="dockerfile-ort"}
PARALLEL=${PARALLEL:="0"}
HTEC=${HTEC:="0"}
DATESTAMP=`date '+%Y%m%d'`
CACHE=${CACHE:="--no-cache"}
BUILDARGS=""

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd ../dockerfiles

if [ "$PARALLEL" == "0" ]; then
    sed -e 's/--parallel//g' $DOCKERFILE > ${DOCKERFILE}s
    DOCKERFILE=${DOCKERFILE}s
fi
if [ "$HTEC" != "0" ]; then
    BUILDARGS="$BUILDARGS --build-arg ort_repository=https://github.com/migraphx-benchmark/onnxruntime --build-arg ort_branch=673bcb77"
fi

docker build ${CACHE} ${BUILDARGS} -f $DOCKERFILE -t ort:${DATESTAMP} .

