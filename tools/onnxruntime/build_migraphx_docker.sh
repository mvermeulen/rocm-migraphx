#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.migraphx ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.migraphx is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd onnxruntime/dockerfiles
docker build -f Dockerfile.migraphx -t rocm-migraphx-ort:$DATESTAMP .
