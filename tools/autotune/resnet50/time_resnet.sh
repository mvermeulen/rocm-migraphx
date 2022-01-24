#!/bin/bash

MODELDIR=${MODELDIR:="/home/mev/source/rocm-migraphx/tools/autotune/resnet50"}

# set up structure
if [ -d /root/.config/miopen ]; then
    echo /root/.config/miopen exists!
    exit 1
fi
if [ ! -d /root/.config ]; then
    mkdir /root/.config
fi

if [ ! -d /root/.config/miopen.empty ]; then
    mkdir /root/.config/miopen.empty
fi

while read destdir sourcedir
do
    if [ -d $destdir ]; then
	rm -rf $destdir
    fi
    cp -r $sourcedir $destdir
done <<MIOPEN_LIST
/root/.config/miopen.migraphx.fusion   /home/mev/source/rocm-migraphx/tools/autotune/resnet50/1.migraphx.fusion/miopen
/root/.config/miopen.migraphx.nofusion /home/mev/source/rocm-migraphx/tools/autotune/resnet50/2.migraphx.nofusion/miopen
/root/.config/miopen.miopen.fusion     /home/mev/source/rocm-migraphx/tools/autotune/resnet50/3.miopen.fusion/miopen
/root/.config/miopen.miopen.nofusion   /home/mev/source/rocm-migraphx/tools/autotune/resnet50/4.miopen.nofusion/miopen
MIOPEN_LIST

cd /root
while read config
do
    echo $config
    ln -s ./config/miopen.${config} ./config/miopen
    /src/AMDMIGraphX/build/bin/driver perf /home/mev/source/rocm-migraphx/saved-models/torchvision/resnet50i1.onnx 1>${config}.fusion.stdout 2>${config}.fusion.stderr
    grep "Total time" ${config}.fusion.stdout
    env MIGRAPHX_DISABLE_MIOPEN_FUSION=1 /src/AMDMIGraphX/build/bin/driver perf /home/mev/source/rocm-migraphx/saved-models/torchvision/resnet50i1.onnx 1>${config}.nofusion.stdout 2>${config}.nofusion.stderr
    grep "Total time" ${config}.nofusion.stdout
    rm ./config/miopen.${config}
done <<CONFIGS
empty
migraphx.fusion
migraphx.nofusion
miopen.fusion
miopen.nofusion
CONFIGS

