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
sed -e 's/debian/3.3/g' Dockerfile.migraphx > Dockerfile.migraphx-rocm33
docker build -f Dockerfile.migraphx-rocm33 -t rocm-migraphx-ort:$DATESTAMP-rocm33 .
