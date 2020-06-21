#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.migraphx ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.migraphx is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cp miopen33/*.txt miopen33/*.udb miopen33/*.lock onnxruntime/dockerfiles
cd onnxruntime/dockerfiles
sed -e 's/debian/3.3/g' -e 's/onnxruntime cmake-3.14.3-Linux-x86_64/cmake-3.14.3-Linux-x86_64/g' Dockerfile.migraphx > Dockerfile.migraphx-rocm33
echo "RUN apt-get install -y time bc" >> Dockerfile.migraphx-rocm33
echo "COPY gfx906_60.HIP.2_3_0.ufdb.txt miopen.udb miopen.udb.lock /root/.config/miopen/" >> Dockerfile.migraphx-rocm33
docker build -f Dockerfile.migraphx-rocm33 -t rocm-migraphx-ort:$DATESTAMP-rocm33 .
