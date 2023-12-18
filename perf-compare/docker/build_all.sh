#!/bin/bash
TAG=${TAG:="6.0"}
DATESTAMP=`date '+%Y%m%d-%H%M'`

docker build -f rocm-dev -t rocm:${TAG} --build-arg install_script="https://repo.radeon.com/amdgpu-install/6.0/ubuntu/jammy/amdgpu-install_6.0.60000-1_all.deb" . 2>&1 | tee rocm:${TAG}.${DATESTAMP}.log
docker build -f migraphx-dev -t migraphx:${TAG} --build-arg base_docker=rocm:${TAG} . 2>&1 | tee migraphx:${TAG}.${DATESTAMP}.log
docker build -f ort-migraphx-dev -t ort-migraphx:${TAG} --build-arg base_docker=migraphx:${TAG} . 2>&1 | tee ort-migraphx:${TAG}.${DATESTAMP}.log
