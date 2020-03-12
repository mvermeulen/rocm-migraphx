#!/bin/bash
#
# Build frozen protobuf for models from http://github.com/tensorflow/models
# in the research/slim subdirectory
if [ ! -d models ]; then
    git clone https://github.com/tensorflow/models
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
tar xf inception_v3_2016_08_28.tar.gz

# InceptionV3
tar xf inception_v4_2016_09_09.tar.gz
python3 ./models/research/slim/export_inference_graph.py --model_name=inception_v4 --output_file=inception_v4_model1.pb
python3 ./models/research/slim/export_inference_graph.py --model_name=inception_v4 --output_file=inception_v4_model1.pb
python3 ./models/research/slim/export_inference_graph.py --model_name=inception_v4 --batch_size=16 --output_file=inception_v4_model16.pb


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
