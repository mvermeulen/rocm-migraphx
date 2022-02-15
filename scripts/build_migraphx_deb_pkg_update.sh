#!/bin/bash
#
# script to build MIGraphX .deb packages from existing package
CACHE=${CACHE:="--no-cache"}
UPDATE=${UPDATE:="migraphx:develop"}

if [ "$IMAGE" = "" ]; then
    IMAGE=migraphx:`date '+%Y%m%d'`
fi

cd ../dockerfiles
docker build ${CACHE} -f dockerfile-pkg-update --build-arg update_image=${UPDATE} -t ${IMAGE} .
