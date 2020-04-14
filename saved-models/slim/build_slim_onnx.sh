#!/bin/bash

# prerequisites:
# pip3 install tf2onnx
python3 -m tf2onnx.convert --checkpoint inception3/inception_v3.ckpt --inputs input --outputs InceptionV3/Predictions/Reshape_1 --output inceptionv3_i1.onnx
