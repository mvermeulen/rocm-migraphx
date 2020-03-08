This directory contains saved models (ONNX, TF protobuf) that can be mounted
to a dockerfile for performance runs.  In general, this directory has either
scripts to generate the models or pointers of where to download them.

These include:
   torchvision - saved ONNX models as part of PyTorch
   onnxruntime - saved ONNX/TF models from the ONNX runtime project
   cadene      - saved ONNX models from Remi Cadene
   onnx-model-zoo - saved ONNX models from the model zoo
   slim        - saved TF models from Slim model repository

To be added models for BERT, Transformers,...
