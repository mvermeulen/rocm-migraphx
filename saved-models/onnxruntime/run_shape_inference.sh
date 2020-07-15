#!/bin/bash
SHAPE_INFER_SCRIPT=${SHAPE_INFER_SCRIPT:="../../tools/onnxruntime/onnxruntime/onnxruntime/core/providers/nuphar/scripts/symbolic_shape_infer.py"}

if [ ! -f ${SHAPE_INFER_SCRIPT} ]; then
    echo $SHAPE_INFER_SCRIPT not found
fi

while read input output
do
      echo python3 $SHAPE_INFER_SCRIPT --input $input --output $output --auto_merge    
      python3 $SHAPE_INFER_SCRIPT --input $input --output $output --auto_merge
done <<INFERLIST
opset10/BERT_Squad/bertsquad10.onnx inferred/BERT_Squad/bertsquad10_inf.onnx
opset10/faster_rcnn/faster_rcnn_R_50_FPN_1x.onnx inferred/faster_rcnn/faster_rcnn_R_50_FPN_1x_inf.onnx
opset10/mask_rcnn/mask_rcnn_R_50_FPN_1x.onnx inferred/mask_rcnn/mask_rcnn_R_50_FPN_1x_inf.onnx
INFERLIST

