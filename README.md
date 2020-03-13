# Overview
This repository contains dockerfiles, scripts and artifacts related to
AMD MIGraphX inference library.

To get started use:
   scripts/build_migraphx_docker.sh
to build a docker image including a copy of MIGraphX.  Next run the docker
image in a container with rocm-migraphx mounted (to create and save artifacts).

In this repository are the following components:

   scripts/
      build_migraphx_docker.sh - build MIGraphX docker container
         build_prereqs.sh - script that builds prereq components
         build_migraphx.sh - script that builds a checked out edition of MIGraphX
         build_check.sh - script to run unit tests
      build_migraphx_docker_latest.sh - create updated MIGraphX container with latest sources.
      run_perf.sh - run predefined performance tests
   dockerfile/   - dockerfiles, generally used by the scripts
   test-results/ - directory where results of run_perf.sh are placed
   saved-models/ - pointers and scripts to create saved ONNX and TF models
      torchvision - PyTorch torchvision suite -> ONNX
      cadene      - PyTorch repository of saved models -> ONNX
      pytorch-examples - PyTorch examples for RNNs -> ONNX
      onnxruntime - Repository of ONNX runtime saved models
      slim - Tensorflow Slim models
      onnx-model-zoo - ONNX model zoo
   tools/ - tools used to create/save/run models, etc.