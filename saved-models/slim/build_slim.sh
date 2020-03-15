#!/bin/bash
#
# Build frozen protobuf for models from http://github.com/tensorflow/models
# in the research/slim subdirectory
# Note: Slim models seem to work with TF 1.12
EXPORT_GRAPH=${EXPORT_GRAPH:="../models/research/slim/export_inference_graph.py"}
FREEZE_GRAPH=${FREEZE_GRAPH:="../../../tools/tensorflow/bazel-bin/tensorflow/python/tools/freeze_graph"}
if [ ! -d models ]; then
    git clone https://github.com/tensorflow/models
    git checkout v1.13.0
else
    cd models
    git pull
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
storage.googleapis.com/mobilenet_v2/checkpoints/mobilenet_v2_1.4_224.tgz        
storage.googleapis.com/download.tensorflow.org/models/nasnet-a_large_04_10_2017.tar.gz
FILELIST

# InceptionV3
if [ ! -d inception3 ]; then
    mkdir inception3
fi
cd inception3
tar xf ../inception_v3_2016_08_28.tar.gz
python3 ${EXPORT_GRAPH} --model_name=inception_v3 --output_file=./inceptionv3_model1.pb --batch_size=1
python3 ${EXPORT_GRAPH} --model_name=inception_v3 --output_file=./inceptionv3_model32.pb --batch_size=32
${FREEZE_GRAPH} \
    --input_graph=./inception_model1.pb \
    --input_binary=true \
    --input_checkpoint=./inception_v3.ckpt \
    --output_node_names=InceptionV3/Predictions/Reshape_1 \
    --output_graph=../inceptionv3_i1.pb
${FREEZE_GRAPH} \
    --input_graph=./inception_model32.pb \
    --input_binary=true \
    --input_checkpoint=./inception_v3.ckpt \
    --output_node_names=InceptionV3/Predictions/Reshape_1 \
    --output_graph=../inceptionv3_i32.pb
cd ..
exit 0

# InceptionV4
tar xf inception_v4_2016_09_09.tar.gz

# Mobilenet
tar xf mobilenet_v2_1.4_224.tgz

# NASNetALarge
tar xf nasnet-a_large_04_10_2017.tar.gz

# ResNet V1
tar xf resnet_v1_50_2016_08_28.tar.gz

# ResNet V2
tar xf resnet_v2_50_2017_04_14.tar.gz

# vgg 16
tar xf vgg_16_2016_08_28.tar.gz
