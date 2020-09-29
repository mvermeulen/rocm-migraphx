#!/bin/bash
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

if [ -d /extra ]; then
    EXTRAMOUNT="-v /extra:/extra"
else
    EXTRAMOUNT=""
fi

docker run -it --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev:/home/mev $EXTRAMOUNT rocm-migraphx:20200928 /bin/bash
