#!/bin/bash
DOCKER=${DOCKER:="ort:cuda-20220406"}

docker run -e EXPROVIDER="tensorrt" -e TZ=America/Chicago --gpus all --network=host -v /home/mev/:/home/mev ${DOCKER} /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh

docker run -e EXPROVIDER="cuda" -e TZ=America/Chicago --gpus all --network=host -v /home/mev/:/home/mev ${DOCKER} /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh
