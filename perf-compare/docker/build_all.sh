#!/bin/bash
TAG=${TAG:="5.7.2"}
DATESTAMP=`date '+%Y%m%d-%H%M'`

docker build -f rocm-dev -t rocm:${TAG} . 2>&1 | tee rocm:${TAG}.${DATESTAMP}.log
docker build -f migraphx-dev -t migraphx:${TAG} --build-arg base_docker=rocm:${TAG} . 2>&1 | tee migraphx:${TAG}.${DATESTAMP}.log
docker build -f ort-migraphx-dev -t ort-migraphx:${TAG} --build-arg base_docker=migraphx:${TAG} . 2>&1 | tee ort-migraphx:${TAG}.${DATESTAMP}.log
