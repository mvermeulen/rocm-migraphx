#!/bin/bash
export DOCKERIMAGE=rocm-migraphx:5.0-rc2
export TUNING_FILE=resnet50_nofusion.conv
export MIGXTUNING_TEMPLATE=../migxtuning_template.sh

../run_migxtuning_docker.sh

export FUSION_SETTING="MIGRAPHX_DISABLE_MIOPEN_FUSION=0"
../run_migxtuning_docker.sh
