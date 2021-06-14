#!/bin/bash
CACHE=${CACHE:="--no-cache"}
DATESTAMP=`date '+%Y%m%d'`
if [ ! -f onnxruntime/dockerfiles/Dockerfile.migraphx ]; then
    echo "onnxruntime/dockerfiles/Dockerfile.migraphx is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi
cp calc-median miopen37/*.txt miopen37/*.udb miopen37/*.lock onnxruntime/dockerfiles
cd onnxruntime/dockerfiles
sed -e 's/onnxruntime cmake-3.14.3-Linux-x86_64/cmake-3.14.3-Linux-x86_64/g' -e 's/--parallel//g' -e 's/debian/3.7/g' -e 's/migraphx_for_ort/develop/g' Dockerfile.migraphx > Dockerfile.migraphx-rocm37
echo "RUN apt-get install -y time bc" >> Dockerfile.migraphx-rocm37
echo "COPY gfx906_60.HIP.2_6_0_8145-rocm-rel-3.7-20-c16087a4.ufdb.txt miopen_1.0.0.udb miopen.udb.lock /root/.config/miopen/" >> Dockerfile.migraphx-rocm37
echo "COPY calc-median /usr/bin/calc-median" >> Dockerfile.migraphx-rocm37
echo "ENV EXPROVIDER=migraphx" >> Dockerfile.migraphx-rocm37

docker build ${CACHE} -f Dockerfile.migraphx-rocm37 -t ort:migraphx-rocm37-$DATESTAMP .
