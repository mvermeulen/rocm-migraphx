#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd ../dockerfiles
docker build -t rocm-migraphx:${DATESTAMP} -f ../dockerfiles/dockerfile-daily .
