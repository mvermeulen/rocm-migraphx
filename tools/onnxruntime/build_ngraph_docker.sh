#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.ngraph ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.ngraph is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cd onnxruntime/dockerfiles
sed 's?rm -rf /code/onnxruntime /code?rm -rf /code?g' Dockerfile.ngraph > Dockerfile.ngraph-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.ngraph-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.ngraph-ort
echo "ENV EXPROVIDER=ngraph" >> Dockerfile.ngraph-ort

docker build -f Dockerfile.ngraph-ort -t ort:ngraph-$DATESTAMP .
