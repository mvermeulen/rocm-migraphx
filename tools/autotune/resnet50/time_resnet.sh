#!/bin/bash

MODELDIR=${MODELDIR:="/home/mev/source/rocm-migraphx/tools/autotune/resnet50"}

# set up structure
if [ -d /root/.config/miopen ]; then
    echo /root/.config/miopen exists!
    exit 1
fi

if [ ! -d /root/.config/miopen.empty ]; then
    mkdir -p /root/.config/miopen.empty
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
/root/.config/miopen.migraphx45.fusion /home/mev/source/rocm-migraphx/tools/autotune/resnet50/5.migraphx45.fusion/miopen
/root/.config/miopen.migraphx45.nofusion /home/mev/source/rocm-migraphx/tools/autotune/resnet50/6.migraphx45.nofusion/miopen
/root/.config/miopen.migraphx45.total /home/mev/source/rocm-migraphx/tools/autotune/resnet50/7.migraphx45.total/miopen
MIOPEN_LIST

cd /root
while read config
do
    echo $config
    if [ ! -d results/$config ]; then
	mkdir -p results/$config
    fi
    cp -r ./.config/miopen.${config} ./.config/miopen
    /home/mev/source/rocm-migraphx/tools/autotune/dump_dbconv.sh ./.config/miopen/*.udb > results/${config}/miopendb.txt
    /src/AMDMIGraphX/build/bin/driver perf /home/mev/source/rocm-migraphx/saved-models/torchvision/resnet50i1.onnx 1>results/${config}/fusion.stdout 2>results/${config}/fusion.stderr
    /home/mev/source/rocm-migraphx/tools/autotune/perfreport_conv.sh results/${config}/fusion.stdout > results/${config}/fusion.timing
    grep "Total time" results/${config}/fusion.stdout
    env MIGRAPHX_DISABLE_MIOPEN_FUSION=1 /src/AMDMIGraphX/build/bin/driver perf /home/mev/source/rocm-migraphx/saved-models/torchvision/resnet50i1.onnx 1>results/${config}/nofusion.stdout 2>results/${config}/nofusion.stderr
    /home/mev/source/rocm-migraphx/tools/autotune/perfreport_conv.sh results/${config}/nofusion.stdout > results/${config}/nofusion.timing    
    grep "Total time" results/${config}/nofusion.stdout
    rm -rf ./.config/miopen
done <<CONFIGS
empty
migraphx.fusion
migraphx.nofusion
miopen.fusion
miopen.nofusion
migraphx45.fusion
migraphx45.nofusion
migraphx45.total
CONFIGS

