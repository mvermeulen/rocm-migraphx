docker run --gpus all --network=host -v /home/mev:/home/mev mevermeulen/ort:tensorrt-20200907 env EXPROVIDER=tensorrt /home/mev/source/rocm-migraphx/scripts/run_ort_infer.sh
