docker run --gpus all --network=host -v /home/mev:/home/mev ort:tensorrt-20201019 env EXPROVIDER=tensorrt /home/mev/source/rocm-migraphx/scripts/run_ort_infer.sh
