#!/bin/bash
DOCKER=${DOCKER:="ort:cpu-20220406"}

docker run -e EXPROVIDER="cpu" -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev/:/home/mev ${DOCKER} /home/mev/source/rocm-migraphx/tools/onnxruntime/ort_benchmark.sh
