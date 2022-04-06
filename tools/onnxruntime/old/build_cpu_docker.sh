#!/bin/bash
CACHE=${CACHE:="--no-cache"}
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.source ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.source is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cp calc-median onnxruntime
cd onnxruntime/dockerfiles
cp Dockerfile.source Dockerfile.source-ort
echo "" >> Dockerfile.source-ort
echo "COPY --from=0 /code/build/Linux/Release /code/onnxruntime/build/Linux/Release" >> Dockerfile.source-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.source-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.source-ort
echo "ENV EXPROVIDER=cpu" >> Dockerfile.source-ort
cd ..
docker build ${CACHE} -f dockerfiles/Dockerfile.source-ort -t ort:cpu-$DATESTAMP .
