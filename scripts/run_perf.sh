#!/bin/bash
#
# saved model directory mounted to the docker image
SAVED_MODELS=${SAVED_MODELS:="/media/mev/EXTRA/rocm-migraphx/saved-models"}
DRIVER=${DRIVER:="/src/AMDMIGraphX/build/bin/driver"}

# run predefined list of test files, all these relative to SAVED_MODELS dir
while read savefile
do
    ls $SAVED_MODELS/savefile
done <<MODELLIST
onnxruntime/opset11/tf_resnet_v2_50/model.onnx
onnxruntime/opset11/tf_resnet_v2_50/model.tf.pb
MODELLIST


