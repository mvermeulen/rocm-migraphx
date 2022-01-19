#!/bin/bash
DOCKERFILE=${DOCKERFILE:="Dockerfile.tuning"}
DOCKERIMAGE=${DOCKERIMAGE:="rocm-tuning:latest"}

docker build -f ${DOCKERFILE} -t ${DOCKERIMAGE} .
