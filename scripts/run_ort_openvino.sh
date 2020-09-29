docker run --network=host -v /home/mev:/home/mev mevermeulen/ort:openvino-20200928 env EXPROVIDER=openvino /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
