#!/bin/bash
#
# Script to build docker image with MIGraphX, run as root
#
set -x
#
# Parameters
ROCM_RELEASE=${ROCM_RELEASE:="3.1"}
ROCM_BASE=${ROCM_BASE:="rocm/dev-ubuntu-18.04:${ROCM_RELEASE}"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

docker build -t rocm-migraphx:${ROCM_RELEASE} -f dockerfile \
       --build-arg ROCM_BASE=${ROCM_BASE} \
       .
