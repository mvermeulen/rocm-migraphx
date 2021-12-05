#!/bin/bash
CACHE=${CACHE:="--no-cache"}
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.tensorrt ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.tensorrt is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cp calc-median onnxruntime
cd onnxruntime/dockerfiles
sed 's/onnxruntime cmake-3.14.3-Linux-x86_64/cmake-3.14.3-Linux-x86_64/g' Dockerfile.tensorrt > Dockerfile.tensorrt-ort
echo "ENV LD_LIBRARY_PATH=" >> Dockerfile.tensorrt-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.tensorrt-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.tensorrt-ort
echo "ENV EXPROVIDER=tensorrt" >> Dockerfile.tensorrt-ort
cd ..

docker build ${CACHE} -f dockerfiles/Dockerfile.tensorrt-ort -t ort:tensorrt-$DATESTAMP .
