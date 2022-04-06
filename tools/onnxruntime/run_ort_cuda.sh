#!/bin/bash
DOCKER=${DOCKER:="ort:cuda-20220406"}

#docker run -e TZ=America/Chicago --gpus all --network=host -v /home/mev/:/home/mev ${DOCKER} env EXPROVIDER="tensorrt" /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh

docker run -e TZ=America/Chicago --gpus all --network=host -v /home/mev/:/home/mev ${DOCKER} env EXPROVIDER="cuda" /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh
