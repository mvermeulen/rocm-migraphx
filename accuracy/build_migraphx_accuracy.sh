#!/bin/bash
#
# Script to build docker image with MIGraphX, run as root
#
set -x
#
# Parameters
DATESTAMP=`date '+%Y%m%d'`
TAG=${NAME:="accuracy-${DATESTAMP}"}
ROCM_BASE=${ROCM_BASE:="rocm/dev-ubuntu-18.04:4.5-complete"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

DOCKERFILE=dockerfile.`date '+%Y-%m-%d'`

# use sed to create updated dockerfile.  Some might work with ARGs but
# had difficulties with substitutions
sed -e "s?ROCM_BASE?${ROCM_BASE}?g" dockerfile > $DOCKERFILE

docker build --no-cache -t rocm-migraphx:${TAG} -f $DOCKERFILE \
       .
