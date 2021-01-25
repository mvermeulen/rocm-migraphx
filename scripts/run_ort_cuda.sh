docker run -e TZ=America/Chicago --gpus all --network=host -v /home/mev:/home/mev ort:cuda-20210125 env EXPROVIDER=cuda /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
