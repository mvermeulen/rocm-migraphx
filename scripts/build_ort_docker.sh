#!/bin/bash
set -x
DOCKERFILE=${DOCKERFILE:="dockerfile-ort"}
PARALLEL=${PARALLEL:="0"}
DATESTAMP=`date '+%Y%m%d'`
CACHE=${CACHE:="--no-cache"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd ../dockerfiles

if [ "$PARALLEL" == "0" ]; then
    sed -e 's/--parallel//g' $DOCKERFILE > ${DOCKERFILE}s
    DOCKERFILE=${DOCKERFILE}s
fi


docker build ${CACHE} -f $DOCKERFILE -t ort:${DATESTAMP} .

