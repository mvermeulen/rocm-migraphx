docker run --gpus all --network=host -v /home/mev:/home/mev ort:cuda-20201109 env EXPROVIDER=cuda /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
