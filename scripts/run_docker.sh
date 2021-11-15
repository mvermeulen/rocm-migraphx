#!/bin/bash
DOCKER=${DOCKER:="rocm-migraphx:20211115"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

if [ -d /extra ]; then
    EXTRAMOUNT="-v /extra:/extra"
else
    EXTRAMOUNT=""
fi

docker run -it -e TZ=America/Chicago -e TARGET=gpu --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev:/home/mev $EXTRAMOUNT $DOCKER /bin/bash
