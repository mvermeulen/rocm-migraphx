#!/bin/bash
#
# Script to build docker image including hip-clang
set -x

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

cd ../dockerfiles
DOCKERFILE=dockerfile-rocm35-12

docker build -t rocm-migraphx:rocm35-12 -f ${DOCKERFILE} .
