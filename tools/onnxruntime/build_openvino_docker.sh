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
sed 's?/code/onnxruntime /code/cmake-3.14.3-Linux-x86_64?/code/cmake-3.14.3-Linux-x86_64?g' Dockerfile.openvino > Dockerfile.openvino-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.openvino-ort

docker build -f Dockerfile.openvino-ort -t openvino-ort:$DATESTAMP .
