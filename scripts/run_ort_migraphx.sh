#!/bin/bash
DOCKER=${DOCKER:="ort:migraphx-rocm37-20210517"}

docker run -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev:/home/mev ${DOCKER} env EXPROVIDER=migraphx /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
