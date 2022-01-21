#!/bin/bash
DOCKERFILE=${DOCKERFILE:="Dockerfile.tuning"}
DOCKERBASE=${DOCKERBASE:="rocm/dev-ubuntu-20.04:5.0-rc2"}
DOCKERIMAGE=${DOCKERIMAGE:="rocm-tuning:20.04-5.0-rc2"}

docker build -f ${DOCKERFILE} --build-arg base_image=${DOCKERBASE} -t ${DOCKERIMAGE} .
