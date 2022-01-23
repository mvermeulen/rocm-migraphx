#!/bin/bash
DRIVER=${DRIVER:="/src/AMDMIGraphX/build/bin/driver"}
MODEL=${MODEL:="/home/mev/source/rocm-migraphx/saved-models/torchvision/resnet50i1.onnx"}

env MIOPEN_ENABLE_LOGGING_CMD=1 $DRIVER run --onnx ${MODEL} 1> resnet50_fusion.out 2> resnet50_fusion.err
env MIOPEN_ENABLE_LOGGING_CMD=1 MIGRAPHX_DISABLE_MIOPEN_FUSION=1 $DRIVER run --onnx ${MODEL} 1> resnet50_nofusion.out 2> resnet50_nofusion.err

fgrep LogCmdConvolution resnet50_fusion.err | awk '{ $1=""; $2=""; $3=""; print $0 }' > resnet50_fusion.conv
fgrep LogCmdConvolution resnet50_nofusion.err | awk '{ $1=""; $2=""; $3=""; print $0 }' > resnet50_nofusion.conv
