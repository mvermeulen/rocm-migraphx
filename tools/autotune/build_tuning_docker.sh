#!/bin/bash
DOCKERFILE=${DOCKERFILE:="Dockerfile.tuning"}
DOCKERBASE=${DOCKERBASE:="rocm/dev-ubuntu-18.04:5.0-rc2"}
DOCKERIMAGE=${DOCKERIMAGE:="rocm-tuning:18.04-5.0-rc2"}

docker build -f ${DOCKERFILE} --build-arg base_image=${DOCKERBASE} -t ${DOCKERIMAGE} .
