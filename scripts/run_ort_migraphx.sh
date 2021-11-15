#!/bin/bash
DOCKER=${DOCKER:="ort:migraphx-rocm45-20211115"}

docker run -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev:/home/mev ${DOCKER} env EXPROVIDER=migraphx /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
