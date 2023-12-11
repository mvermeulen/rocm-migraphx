#!/bin/bash
#
# Set up environment and run resnet50
if [ ! -f setup_venv.sh ]; then
    echo "missing setup_venv.sh are you in the SHARK directory?"
    exit 0
fi

PYTHON=python3.11 VENV_DIR=1211_venv IMPORTER=1 ./setup_venv.sh
source

python -m shark.examples.shark_inference.resnet50_script --device=vulkan

deactivate
