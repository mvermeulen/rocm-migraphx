#!/bin/bash
SETUP=1
GLUE_TASK=${GLUE_TASK:="MRPC"}

if [ ! -d transformers ]; then
    git clone https://github.com/huggingface/transformers
    cd transformers/examples
    git apply ../../run_glue.diff
    cd ../..
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
if [ ! -f bert_mrpc1.onnx ]; then
    python3 run_glue.py \
	    --model_type bert \
	    --model_name_or_path bert-base-cased \
	    --per_gpu_eval_batch_size 1 \
	    --task_name ${GLUE_TASK} \
	    --do_eval \
	    --do_train \
	    --output_dir ./checkpoint/ \
	    --data_dir ../../../../datasets/glue/glue_data/${GLUE_TASK}
    cp bert_mrpc1.onnx ../..
    rm -rf checkpoint
fi

if [ ! -f bert_mrpc8.onnx ]; then
    python3 run_glue.py \
	    --model_type bert \
	    --model_name_or_path bert-base-cased \
	    --per_gpu_eval_batch_size 8 \
	    --task_name ${GLUE_TASK} \
	    --do_eval \
	    --do_train \
	    --output_dir ./checkpoint/ \
	    --data_dir ../../../../datasets/glue/glue_data/${GLUE_TASK}
    cp bert_mrpc8.onnx ../..
    rm -rf checkpoint    
fi

