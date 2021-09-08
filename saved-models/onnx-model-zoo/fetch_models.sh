#!/bin/bash
while read onnxfile location
do
    if [ ! -f $onnxfile ]; then
	wget $location
    fi
done <<MODELLIST
bertsquad-10.onnx	https://github.com/onnx/models/raw/master/text/machine_comprehension/bert-squad/model/bertsquad-10.onnx
roberta-base-11.onnx	https://github.com/onnx/models/blob/master/text/machine_comprehension/roberta/model/roberta-base-11.onnx
t5-encoder-12.onnx	https://github.com/onnx/models/blob/master/text/machine_comprehension/t5/model/t5-encoder-12.onnx
yolov4.onnx		https://github.com/onnx/models/blob/master/vision/object_detection_segmentation/yolov4/model/yolov4.onnx
MaskRCNN-10.onnx	https://github.com/onnx/models/blob/master/vision/object_detection_segmentation/mask-rcnn/model/MaskRCNN-10.onnx
ResNet101-DUC-7.onnx	https://github.com/onnx/models/blob/master/vision/object_detection_segmentation/duc/model/ResNet101-DUC-7.onnx
super-resolution-10.onnx	https://github.com/onnx/models/blob/master/vision/super_resolution/sub_pixel_cnn_2016/model/super-resolution-10.onnx
arcfaceresnet100-8.onnx		https://github.com/onnx/models/blob/master/vision/body_analysis/arcface/model/arcfaceresnet100-8.onnx
MODELLIST
