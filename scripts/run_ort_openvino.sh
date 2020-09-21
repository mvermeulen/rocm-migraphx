docker run --network=host -v /home/mev:/home/mev mevermeulen/ort:openvino-20200921 env EXPROVIDER=cpu /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
