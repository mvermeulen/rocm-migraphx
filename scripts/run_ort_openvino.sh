#!/bin/bash
if [ -d /extra ]; then
    EXTRAMOUNT="-v /extra:/extra"
else
    EXTRAMOUNT=""
fi

docker run --network=host -v /home/mev:/home/mev $EXTRAMOUNT ort:openvino-20201019 env EXPROVIDER=openvino /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
