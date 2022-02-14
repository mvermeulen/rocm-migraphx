#!/bin/bash
ONNXRUNNER=${ONNXRUNNER:="/workspace/github/onnxruntime/build/Release/onnx_test_runner"}
DOCKER=${DOCKER:="mevermeulen/ort:rocm-20220214"}

docker run -e TZ=America/Chicago --gpus all --network=host -v /home/mev:/home/mev ${DOCKER} env EXPROVIDER=rocm ONNXRUNNER=${ONNXRUNNER} /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
