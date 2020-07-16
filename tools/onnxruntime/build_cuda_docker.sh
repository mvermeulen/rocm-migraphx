#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.cuda ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.cuda is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd onnxruntime/dockerfiles
sed 's/onnxruntime cmake-3.14.3-Linux-x86_64/cmake-3.14.3-Linux-x86_64/g' Dockerfile.cuda > Dockerfile.cuda-ort
echo "RUN apt-get install -y time bc calc-stats" >> Dockerfile.cuda-ort
echo "ENV EXPROVIDER=cuda" >> Dockerfile.cuda-ort

docker build --no-cache -f Dockerfile.cuda-ort -t ort:cuda-$DATESTAMP .
