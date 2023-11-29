#!/bin/bash
DOCKER=${DOCKER:="cuda-tvm:12"}

if [ `id -u` != 0 ]; then
    echo script should be run as root
    exit 0
fi

docker run -it -e NVIDIA_DRIVER_CAPABILITIES=compute,graphics,utility \
       --gpus all \
       -v /home/mev:/home/mev \
       -v /etc/vulkan/icd.d:/etc/vulkan/icd.d \
       -v /usr/share/vulkan/icd.d:/usr/share/vulkan/icd.d \
       -v /etc/glvnd/egl_vendor.d/:/etc/glvnd/egl_vendor.d \
       -v /usr/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d \
       $DOCKER /bin/bash
