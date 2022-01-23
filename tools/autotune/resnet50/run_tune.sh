#!/bin/bash
export DOCKERIMAGE=rocm-tuning:18.04-5.0-rc2
export TUNING_FILE=resnet50_fusion.conv
export TUNING_TEMPLATE=../tuning_template.sh

../run_tuning_docker.sh

export TUNING_FILE=resnet50_nofusion.conv

../run_tuning_docker.sh
