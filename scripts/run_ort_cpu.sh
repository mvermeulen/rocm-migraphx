#!/bin/bash
if [ -d /extra ]; then
    EXTRAMOUNT="-v /extra:/extra"
else
    EXTRAMOUNT=""
fi

docker run --network=host -v /home/mev:/home/mev $EXTRAMOUNT ort:cpu-20201109 env EXPROVIDER=cpu /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
