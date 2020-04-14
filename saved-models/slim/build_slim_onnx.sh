#!/bin/bash

# prerequisites:
# pip3 install tf2onnx
python3 -m tf2onnx.convert --saved-model inceptionv3_i1.pb --output inceptionv3_i1.onnx
