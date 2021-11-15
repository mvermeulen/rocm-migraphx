#!/bin/bash
DOCKER=${DOCKER:="ort:openvino-20211115"}

if [ -d /extra ]; then
    EXTRAMOUNT="-v /extra:/extra"
else
    EXTRAMOUNT=""
fi

docker run -e TZ=America/Chicago --network=host -v /home/mev:/home/mev $EXTRAMOUNT ${DOCKER} env EXPROVIDER=openvino /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
