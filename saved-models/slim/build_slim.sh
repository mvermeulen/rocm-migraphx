#!/bin/bash
#
# Build frozen protobuf for models from http://github.com/tensorflow/models
# in the research/slim subdirectory
# Note: Slim models seem to work with TF 1.12
EXPORT_GRAPH=${EXPORT_GRAPH:="../models/research/slim/export_inference_graph.py"}
FREEZE_GRAPH=${FREEZE_GRAPH:="../../../tools/tensorflow/bazel-bin/tensorflow/python/tools/freeze_graph"}
SUMMARIZE_GRAPH=${SUMMARIZE_GRAPH:="../../../tools/tensorflow/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph"}
if [ ! -d models ]; then
    git clone https://github.com/tensorflow/models
    cd models
    git checkout v1.13.0
    cd ..
fi

while read file
do
    base=`basename $file`
    if [ ! -f $base ]; then
	wget http://$file
    fi
done <<FILELIST                                                                 
download.tensorflow.org/models/resnet_v1_50_2016_08_28.tar.gz                   
download.tensorflow.org/models/resnet_v2_50_2017_04_14.tar.gz                   
download.tensorflow.org/models/inception_v3_2016_08_28.tar.gz                   
download.tensorflow.org/models/inception_v4_2016_09_09.tar.gz                   
download.tensorflow.org/models/vgg_16_2016_08_28.tar.gz
download.tensorflow.org/models/mobilenet_v1_2018_02_22/mobilenet_v1_1.0_224.tgz
storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.4_224.tgz
storage.googleapis.com/download.tensorflow.org/models/nasnet-a_large_04_10_2017.tar.gz
FILELIST

# InceptionV3
if [ ! -f inceptionv3_i1.pb -o ! -f inceptionv3_i32.pb ]; then
    if [ -d inception3 ]; then
	rm -rf inception3
    fi
    mkdir inception3
    cd inception3
    tar xf ../inception_v3_2016_08_28.tar.gz
    python3 ${EXPORT_GRAPH} --model_name=inception_v3 --output_file=./inceptionv3_model1.pb --batch_size=1
    python3 ${EXPORT_GRAPH} --model_name=inception_v3 --output_file=./inceptionv3_model32.pb --batch_size=32
    ${SUMMARIZE_GRAPH} --in_graph=inceptionv3_model1.pb > ./inception_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=inceptionv3_model32.pb > ./inception_model32.sum
    ${FREEZE_GRAPH} \
	--input_graph=./inceptionv3_model1.pb \
	--input_binary=true \
	--input_checkpoint=./inception_v3.ckpt \
	--output_node_names=InceptionV3/Predictions/Reshape_1 \
	--output_graph=../inceptionv3_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./inceptionv3_model32.pb \
	--input_binary=true \
	--input_checkpoint=./inception_v3.ckpt \
	--output_node_names=InceptionV3/Predictions/Reshape_1 \
	--output_graph=../inceptionv3_i32.pb
    cd ..
fi

# InceptionV4
if [ ! -f inceptionv4_i1.pb -o ! -f inceptionv4_i16.pb ]; then
    if [ -d inception4 ]; then
	rm -rf inception4
    fi
    mkdir inception4
    cd inception4
    tar xf ../inception_v4_2016_09_09.tar.gz
    python3 ${EXPORT_GRAPH} --model_name=inception_v4 --output_file=./inceptionv4_model1.pb --batch_size=1
    python3 ${EXPORT_GRAPH} --model_name=inception_v4 --output_file=./inceptionv4_model16.pb --batch_size=16
    ${SUMMARIZE_GRAPH} --in_graph=inceptionv4_model1.pb > ./inception_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=inceptionv4_model16.pb > ./inception_model32.sum
    ${FREEZE_GRAPH} \
	--input_graph=./inceptionv4_model1.pb \
	--input_binary=true \
	--input_checkpoint=./inception_v4.ckpt \
	--output_node_names=InceptionV4/Logits/Predictions \
	--output_graph=../inceptionv4_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./inceptionv4_model16.pb \
	--input_binary=true \
	--input_checkpoint=./inception_v4.ckpt \
	--output_node_names=InceptionV4/Logits/Predictions \
	--output_graph=../inceptionv4_i16.pb
    cd ..
fi

# Mobilenet
# V1 exports, but problems exporting V2
if [ ! -f mobilenet_i1.pb -o ! -f mobilenet_i64.pb ]; then
    if [ -d mobilenet ]; then
	rm -rf mobilenet
    fi
    mkdir mobilenet
    cd mobilenet
    tar xf ../mobilenet_v1_1.0_224.tgz
    tar xf ../mobilenet_v2_1.4_224.tgz
    python3 ${EXPORT_GRAPH} --model_name=mobilenet_v1 --output_file=./mobilenetv1_model1.pb --batch_size=1
    python3 ${EXPORT_GRAPH} --model_name=mobilenet_v1 --output_file=./mobilenetv1_model64.pb --batch_size=64
#    python3 ${EXPORT_GRAPH} --model_name=mobilenet_v2 --output_file=./mobilenetv2_model1.pb --batch_size=1
#    python3 ${EXPORT_GRAPH} --model_name=mobilenet_v2 --output_file=./mobilenetv2_model64.pb --batch_size=64
    ${SUMMARIZE_GRAPH} --in_graph=mobilenetv1_model1.pb > ./mobilenetv1_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=mobilenetv1_model64.pb > ./mobilenetv1_model64.sum
    ${FREEZE_GRAPH} \
	--input_graph=./mobilenetv1_model1.pb \
	--input_binary=true \
	--input_checkpoint=./mobilenet_v1_1.0_224.ckpt \
	--output_node_names=MobilenetV1/Predictions/Reshape_1 \
	--output_graph=../mobilenet_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./mobilenetv1_model64.pb \
	--input_binary=true \
	--input_checkpoint=./mobilenet_v1_1.0_224.ckpt \
	--output_node_names=MobilenetV1/Predictions/Reshape_1 \
	--output_graph=../mobilenet_i64.pb
    cd ..
fi

# NASNetALarge
if [ ! -f nasnet_i1.pb -o ! -f nasnet_i16.pb ]; then
    if [ -d nasnet ]; then
	rm -rf nasnet
    fi
    mkdir nasnet
    cd nasnet
    tar xf ../nasnet-a_large_04_10_2017.tar.gz
    python3 ${EXPORT_GRAPH} --model_name=nasnet_large --output_file=./nasnet_model1.pb --batch_size=1
    python3 ${EXPORT_GRAPH} --model_name=nasnet_large --output_file=./nasnet_model16.pb --batch_size=16
    ${SUMMARIZE_GRAPH} --in_graph=nasnet_model1.pb > ./nasnet_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=nasnet_model16.pb > ./nasnet_model16.sum
    ${FREEZE_GRAPH} \
	--input_graph=./nasnet_model1.pb \
	--input_binary=true \
	--input_checkpoint=./model.ckpt \
	--output_node_names=final_layer/predictions \
	--output_graph=../nasnet_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./nasnet_model16.pb \
	--input_binary=true \
	--input_checkpoint=./model.ckpt \
	--output_node_names=final_layer/predictions \
	--output_graph=../nasnet_i16.pb
    cd ..
fi

# ResNet V1
if [ ! -f resnet50v1_i1.pb -o ! -f resnet50v1_i64.pb ]; then
    if [ -d resnet50v1 ]; then
	rm -rf resnet50v1
    fi
    mkdir resnet50v1
    cd resnet50v1
    tar xf ../resnet_v1_50_2016_08_28.tar.gz
    python3 ${EXPORT_GRAPH} --model_name=resnet_v1_50 --output_file=./resnet50v1_model1.pb --batch_size=1 --labels_offset=1
    python3 ${EXPORT_GRAPH} --model_name=resnet_v1_50 --output_file=./resnet50v1_model64.pb --batch_size=64 --labels_offset=1
    ${SUMMARIZE_GRAPH} --in_graph=resnet50v1_model1.pb > ./resnet50v1_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=resnet50v1_model64.pb > ./resnet50v1_model64.sum
    ${FREEZE_GRAPH} \
	--input_graph=./resnet50v1_model1.pb \
	--input_binary=true \
	--input_checkpoint=./resnet_v1_50.ckpt \
	--output_node_names=resnet_v1_50/predictions/Reshape_1 \
	--output_graph=../resnet50v1_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./resnet50v1_model64.pb \
	--input_binary=true \
	--input_checkpoint=./resnet_v1_50.ckpt \
	--output_node_names=resnet_v1_50/predictions/Reshape_1 \
	--output_graph=../resnet50v1_i64.pb
    cd ..
fi

# ResNet V2
if [ ! -f resnet50v2_i1.pb -o ! -f resnet50v2_i64.pb ]; then
    if [ -d resnet50v2 ]; then
	rm -rf resnet50v2
    fi
    mkdir resnet50v2
    cd resnet50v2
    tar xf ../resnet_v2_50_2017_04_14.tar.gz
    python3 ${EXPORT_GRAPH} --model_name=resnet_v2_50 --output_file=./resnet50v2_model1.pb --batch_size=1
    python3 ${EXPORT_GRAPH} --model_name=resnet_v2_50 --output_file=./resnet50v2_model64.pb --batch_size=64
    ${SUMMARIZE_GRAPH} --in_graph=resnet50v2_model1.pb > ./resnet50v2_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=resnet50v2_model64.pb > ./resnet50v2_model64.sum
    ${FREEZE_GRAPH} \
	--input_graph=./resnet50v2_model1.pb \
	--input_binary=true \
	--input_checkpoint=./resnet_v2_50.ckpt \
	--output_node_names=resnet_v2_50/predictions/Reshape_1 \
	--output_graph=../resnet50v2_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./resnet50v2_model64.pb \
	--input_binary=true \
	--input_checkpoint=./resnet_v2_50.ckpt \
	--output_node_names=resnet_v2_50/predictions/Reshape_1 \
	--output_graph=../resnet50v2_i64.pb
    cd ..
fi

# vgg 16
if [ ! -f vgg16_i1.pb -o ! -f vgg16_i16.pb ]; then
    if [ -d vgg16 ]; then
	rm -rf vgg16
    fi
    mkdir vgg16
    cd vgg16
    tar xf ../vgg_16_2016_08_28.tar.gz
    python3 ${EXPORT_GRAPH} --model_name=vgg_16 --output_file=./vgg16_model1.pb --batch_size=1 --labels_offset=1
    python3 ${EXPORT_GRAPH} --model_name=vgg_16 --output_file=./vgg16_model16.pb --batch_size=16 --labels_offset=1
    ${SUMMARIZE_GRAPH} --in_graph=vgg16_model1.pb > ./vgg16_model1.sum
    ${SUMMARIZE_GRAPH} --in_graph=vgg16_model16.pb > ./vgg16_model16.sum
    ${FREEZE_GRAPH} \
	--input_graph=./vgg16_model1.pb \
	--input_binary=true \
	--input_checkpoint=./vgg_16.ckpt \
	--output_node_names=vgg_16/fc8/squeezed \
	--output_graph=../vgg16_i1.pb
    ${FREEZE_GRAPH} \
	--input_graph=./vgg16_model16.pb \
	--input_binary=true \
	--input_checkpoint=./vgg_16.ckpt \
	--output_node_names=vgg_16/fc8/squeezed \
	--output_graph=../vgg16_i16.pb
    cd ..
fi
