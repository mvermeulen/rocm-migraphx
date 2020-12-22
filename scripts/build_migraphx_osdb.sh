#!/bin/bash
#
# Script to build docker image with MIGraphX, run as root
#
set -x
#
# Parameters
BUILDNUM=${BUILDNUM:="6220"}
ROCM_BASE=${ROCM_BASE:="rocm/osdb:${BUILDNUM}"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

cd ../dockerfiles
DOCKERFILE=dockerfile-osdb.${BUILDNUM}-`date '+%Y-%m-%d'`

# use sed to create updated dockerfile.  Some might work with ARGs but
# had difficulties with substitutions
sed -e "s?ROCM_BASE?${ROCM_BASE}?g" dockerfile-osdb > $DOCKERFILE

docker build -t rocm-migraphx:osdb-${BUILDNUM} -f $DOCKERFILE .
