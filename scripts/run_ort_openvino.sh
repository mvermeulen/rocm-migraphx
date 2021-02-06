#!/bin/bash
if [ -d /extra ]; then
    EXTRAMOUNT="-v /extra:/extra"
else
    EXTRAMOUNT=""
fi

docker run -e TZ=America/Chicago --network=host -v /home/mev:/home/mev $EXTRAMOUNT ort:openvino-20210205 env EXPROVIDER=openvino /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
