#!/bin/bash
DOCKER=${DOCKER:="ort:migraphx-20220406"}

docker run -e EXPROVIDER="migraphx" -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev/:/home/mev ${DOCKER} /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh

docker run -e EXPROVIDER="rocm" -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev/:/home/mev ${DOCKER} /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh
