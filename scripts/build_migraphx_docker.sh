#!/bin/bash
#
# Script to build docker image with MIGraphX, run as root
#
set -x
#
# Parameters
ROCM_RELEASE=${ROCM_RELEASE:="5.3"}
COMPLETE=${COMPLETE:="-complete"}
ROCM_BASE=${ROCM_BASE:="rocm/dev-ubuntu-20.04:${ROCM_RELEASE}${COMPLETE}"}
DOCKERIMAGE=${DOCKERIMAGE:="rocm-migraphx:${ROCM_RELEASE}"}
CACHE=${CACHE:="--no-cache"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

cd ../dockerfiles
DOCKERFILE=dockerfile.`date '+%Y-%m-%d'`

# save away dockerfile used to build
cp dockerfile $DOCKERFILE

docker build --build-arg rocm_release=${ROCM_RELEASE} --build-arg base_image=${ROCM_BASE} ${CACHE} -t $DOCKERIMAGE -f $DOCKERFILE .
