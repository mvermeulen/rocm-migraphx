#!/bin/bash
DOCKER=${DOCKER:="ort:tensorrt-20220110"}

docker run -e TZ=America/Chicago --gpus all --network=host -v /home/mev:/home/mev ${DOCKER} env EXPROVIDER=tensorrt /home/mev/source/rocm-migraphx/scripts/run_ort_infer.sh
