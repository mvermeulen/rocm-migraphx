#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.openvino ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.openvino is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd onnxruntime/dockerfiles
sed 's?rm -rf cmake-3.14.3-Linux-x86_64 onnxruntime?rm -rf cmake-3.14.3-Linux-x86_64?g' Dockerfile.openvino > Dockerfile.openvino-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.openvino-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.openvino-ort
echo "ENV EXPROVIDER=openvino" >> Dockerfile.openvino-ort

docker build --no-cache -f Dockerfile.openvino-ort -t ort:openvino-$DATESTAMP .
