#!/bin/bash
DOCKER=${DOCKER:="ort:migraphx-rocm45-20220214"}
LOG_MIOPEN=${LOG_MIOPEN:="0"}

if [ "$LOG_MIOPEN" != "0" ]; then
   MIOPEN_LOGGING="-e MIOPEN_ENABLE_LOGGING_CMD=1 -e MIGRAPHX_DISABLE_MIOPEN_FUSION=1"
else
    MIOPEN_LOGGING=""
fi

docker run -e TZ=America/Chicago --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev:/home/mev ${MIOPEN_LOGGING} ${DOCKER} env EXPROVIDER=migraphx /home/mev/source/rocm-migraphx/scripts/run_ort_mev.sh
