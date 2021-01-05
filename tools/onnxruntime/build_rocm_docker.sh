#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
DOCKERDIR=${DOCKERDIR:="onnxruntime/orttaining/tools/amdgpu"}
DOCKERFILE=${DOCKERFILE:="Dockerfile.rocm4.0.pytorch"}

if [ ! -f ${DOCKERDIR}/${DOCKERFILE} ]; then
    echo "${DOCKERDIR}/${DOCKERFILE} is missing"
    exit 0
fi
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

cd ${DOCKERDIR}
docker build -f ${DOCKERFILE} -t ort:rocm-$DATESTAMP .
