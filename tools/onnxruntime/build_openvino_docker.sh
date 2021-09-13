#!/bin/bash
CACHE=${CACHE:="--no-cache"}
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
sed -e 's?&& rm -rf onnxruntime??g' -e 's?USER ${BUILD_USER}??g' Dockerfile.openvino > Dockerfile.openvino-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.openvino-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.openvino-ort
echo "ENV EXPROVIDER=openvino" >> Dockerfile.openvino-ort
echo "RUN env LD_LIBRARY_PATH= apt-get install -y linux-tools-5.4.0-54-generic linux-cloud-tools-5.4.0-54-generic linux-tools-generic linux-cloud-tools-generic" >> Dockerfile.openvino-ort
cd ..

docker build ${CACHE} -f dockerfiles/Dockerfile.openvino-ort -t ort:openvino-$DATESTAMP .
