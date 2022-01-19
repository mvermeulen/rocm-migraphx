#!/bin/bash
python3 dump_to_onnx2.py --list | while read model
do
    echo $model
    if [ -d $model ]; then
	cd $model
    else
	mkdir $model
	cd $model
	python3 ../dump_to_onnx2.py --name $model 1> dump.out 2> dump.err
    fi
    /src/AMDMIGraphX/build/bin/driver perf ${model}*onnx 1> migraphx.out 2> migraphx.err
    cd ..
done
