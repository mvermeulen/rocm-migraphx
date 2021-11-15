#!/bin/bash
DOCKER=${DOCKER:="ort:rocm-20211115"}

docker run -e TZ=America/Chicago --gpus all --network=host -v /home/mev:/home/mev ${DOCKER} env EXPROVIDER=rocm /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
