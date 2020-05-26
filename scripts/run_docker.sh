#!/bin/bash
if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

docker run -it --device=/dev/dri --device=/dev/kfd --network=host --group-add=video -v /home/mev:/home/mev rocm-migraphx:20200527 /bin/bash
