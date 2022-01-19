#!/bin/bash
CACHE=${CACHE:="--no-cache"}
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.rocm ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.rocm is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cp calc-median onnxruntime/dockerfiles
cd onnxruntime/dockerfiles
sed -e 's/--parallel//g' -e 's/rf onnxruntime/rf/g' Dockerfile.rocm > Dockerfile.rocm-ort
echo "" >> Dockerfile.rocm-ort
echo "RUN apt update && apt-get install -y time bc" >> Dockerfile.rocm-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.rocm-ort
echo "ENV EXPROVIDER=rocm" >> Dockerfile.rocm-ort

docker build ${CACHE} -f Dockerfile.rocm-ort -t ort:rocm-$DATESTAMP .
