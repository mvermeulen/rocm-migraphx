#!/bin/bash

# This works
#python3 benchmark.py -g -o no_opt -b  1 2 4 8 16 -m bert-base-cased --sequence_length 128 --precision fp16 --provider rocm
#python3 benchmark.py -g -o no_opt -b  1 2 4 8 16 -m bert-base-cased --sequence_length 128 --precision fp32 --provider rocm
#python3 benchmark.py -g           -b  1 2 4 8 16 -m bert-base-cased --sequence_length 128 --precision fp16 --provider rocm

# This fails
#python3 profiler.py -g -m onnx_models/bert_base_cased_1.onnx -b 1 -s 128 -g --provider rocm

# This fails (based on develop and migraphx_for_ort)
#python3 benchmark.py -g -o no_opt -b  1 2 4 8 16 -m bert-base-cased --sequence_length 128 --precision fp16 --provider migraphx
#python3 benchmark.py -g -o no_opt -b  1 2 4 8 16 -m bert-base-uncased --sequence_length 128 --precision fp16 --provider migraphx
