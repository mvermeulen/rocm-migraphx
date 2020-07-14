#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.tensorrt ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.tensorrt is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd onnxruntime/dockerfiles
sed 's/onnxruntime cmake-3.14.3-Linux-x86_64/cmake-3.14.3-Linux-x86_64/g' Dockerfile.tensorrt > Dockerfile.tensorrt-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.tensorrt-ort

docker build -f Dockerfile.tensorrt-ort -t ort:tensorrt-$DATESTAMP .
