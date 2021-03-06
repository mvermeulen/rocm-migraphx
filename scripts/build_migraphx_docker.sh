#!/bin/bash
#
# Script to build docker image with MIGraphX, run as root
#
set -x
#
# Parameters
ROCM_RELEASE=${ROCM_RELEASE:="3.10"}
ROCM_BASE=${ROCM_BASE:="rocm/dev-ubuntu-18.04:${ROCM_RELEASE}"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

cd ../dockerfiles
DOCKERFILE=dockerfile.`date '+%Y-%m-%d'`

# use sed to create updated dockerfile.  Some might work with ARGs but
# had difficulties with substitutions
sed -e "s?ROCM_RELEASE?${ROCM_RELEASE}?g" \
    -e "s?ROCM_BASE?${ROCM_BASE}?g" dockerfile > $DOCKERFILE

docker build -t rocm-migraphx:${ROCM_RELEASE} -f $DOCKERFILE \
       .
