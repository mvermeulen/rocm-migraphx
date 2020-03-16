#!/bin/bash
SETUP=0
GLUE_TASK=${GLUE_TASK:="MRPC"}

if [ ! -d transformers ]; then
    git clone https://github.com/huggingface/transformers
else
    cd transformers
    git pull
    cd ..
fi

cd transformers
if [ $SETUP == 1 ]; then
    pip3 install .
    pip3 install -r ./examples/requirements.txt
fi

cd examples
python3 run_glue.py \
	--model_type bert \
	--model_name_or_path bert-base-cased \
	--per_gpu_eval_batch_size 1 \
	--task_name ${GLUE_TASK} \
	--do_eval \
	--do_train \
	--output_dir ./checkpoint/${GLUE_TASK} \
	--data_dir ../../../../datasets/glue/glue_data

    
       
