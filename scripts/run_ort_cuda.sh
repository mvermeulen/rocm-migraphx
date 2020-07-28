docker run --gpus all --network=host -v /home/mev:/home/mev mevermeulen/ort:cuda-20200727 env EXPROVIDER=cuda /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
