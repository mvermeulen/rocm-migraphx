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
cp calc-median onnxruntime
cd onnxruntime/dockerfiles
#cp Dockerfile.cuda Dockerfile.cuda-ort
sed -e 's/--parallel//g' Dockerfile.cuda > Dockerfile.cuda-ort
echo "" >> Dockerfile.cuda-ort
echo "COPY --from=0 /code/build/Linux/Release /code/onnxruntime/build/Linux/Release" >> Dockerfile.cuda-ort
echo "RUN apt-get install -y time bc" >> Dockerfile.cuda-ort
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.cuda-ort
echo "ENV EXPROVIDER=cuda" >> Dockerfile.cuda-ort
cd ..

docker build --no-cache -f dockerfiles/Dockerfile.cuda-ort -t ort:cuda-$DATESTAMP .
