#!/bin/bash
./build_cpu_docker.sh 2>&1 | tee build_cpu.txt
./build_cuda_docker.sh 2>&1 | tee build_cuda.txt
./build_tensorrt_docker.sh 2>&1 | tee build_tensorrt.txt
./build_openvino_docker.sh 2>&1 | tee build_openvino.txt
./build_migraphx_docker.sh 2>&1 | tee build_migraphx.txt
