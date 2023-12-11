#!/bin/bash
TAG=${TAG:="5.7.2"}

docker build -f rocm-dev -t rocm-dev:${TAG} .
docker build -f migraphx-dev -t migraphx-dev:${TAG} --build-arg base_docker=rocm-dev:${TAG} .
docker build -f ort-migraphx-dev -t ort-migraphx:${TAG} --build-arg base_docker=migraphx-dev:${TAG} .
