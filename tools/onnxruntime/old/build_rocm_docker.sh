#!/bin/bash
CACHE=${CACHE:="--no-cache"}
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f Dockerfile.rocm4.5.2.pytorch ]; then
    echo "Dockerfile.rocm4.5.2.pytorch is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cp Dockerfile.rocm4.5.2.pytorch onnxruntime/dockerfiles/Dockerfile.rocm-ort
cp calc-median onnxruntime/dockerfiles
cd onnxruntime/dockerfiles
echo "" >> Dockerfile.rocm-ort
echo "RUN apt update && apt-get install -y time bc" >> Dockerfile.rocm-ort
echo "RUN mkdir /code && ln -s /workspace/github/onnxruntime /code/onnxruntime" >> Dockerfile.rocm-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.rocm-ort
echo "ENV EXPROVIDER=rocm" >> Dockerfile.rocm-ort

docker build ${CACHE} -f Dockerfile.rocm-ort -t ort:rocm-$DATESTAMP .
