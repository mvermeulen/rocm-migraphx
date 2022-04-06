#!/bin/bash
DOCKER=${DOCKER:="ort:migraphx-20220406"}

docker run -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev/:/home/mev ${DOCKER} env EXPROVIDER="migraphx" /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh

docker run -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev/:/home/mev ${DOCKER} env EXPROVIDER="rocm" /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh
