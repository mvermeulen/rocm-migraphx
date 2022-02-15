#!/bin/bash
#
# script to build MIGraphX .deb packages, and save them in the docker file.
CACHE=${CACHE:="--no-cache"}
BRANCH=${BRANCH:="develop"}
BASE=${BASE:="rocm/dev-ubuntu-20.04:5.0-complete"}
IMAGE=${IMAGE:="migraphx:$BRANCH"}

cd ../dockerfiles
docker build ${CACHE} -f dockerfile-pkg --build-arg branch=${BRANCH} --build-arg base_image=${BASE} -t ${IMAGE} .
