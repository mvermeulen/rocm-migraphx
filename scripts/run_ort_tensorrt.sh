docker run --gpus all --network=host -v /home/mev:/home/mev mevermeulen/ort:tensorrt-20200914 env EXPROVIDER=tensorrt /home/mev/source/rocm-migraphx/scripts/run_ort_infer.sh
