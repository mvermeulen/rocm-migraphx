#!/bin/bash
set -x
DATESTAMP=`date '+%Y%m%d'`
BASE=rocm-migraphx:4.2
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd ../dockerfiles
docker build -t rocm-migraphx:${DATESTAMP} --no-cache --build-arg DOCKERBASE=${BASE} -f ../dockerfiles/dockerfile-daily .
