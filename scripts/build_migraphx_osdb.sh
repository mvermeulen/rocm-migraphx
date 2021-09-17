#!/bin/bash
#
# Script to build docker image with MIGraphX, run as root
#
set -x
#
# Parameters
BUILDNUM=${BUILDNUM:="6220"}
ROCM_BASE=${ROCM_BASE:="rocm/osdb:${BUILDNUM}"}
BUILD_NAVI=${BUILD_NAVI:="0"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

cd ../dockerfiles
DOCKERFILE=dockerfile-osdb.${BUILDNUM}-`date '+%Y-%m-%d'`

# use sed to create updated dockerfile.  Some might work with ARGs but
# had difficulties with substitutions
sed -e "s?ROCM_BASE?${ROCM_BASE}?g" -e "s?BUILD_NAVI_CHOICE=${BUILD_NAVI}?g" dockerfile-osdb > $DOCKERFILE

if [ "$BUILD_NAVI" = "0" ]; then
    docker build -t rocm-migraphx:osdb-${BUILDNUM} -f $DOCKERFILE .
else
    docker build -t rocm-migraphx:osdb-${BUILDNUM}n -f $DOCKERFILE .
fi

