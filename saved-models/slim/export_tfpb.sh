#!/bin/bash
SLIMDIR=${SLIMDIR:="/media/mev/EXTRA/tensorflow/models/research/slim"}
TFCPU_FREEZE=${TFCPU_FREEZE:="/home/mev/source/tensorflow/tensorflow-cpu/bazel-bin/tensorflow/python/tools/freeze_graph"}

cd nasnet
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=nasnet_large --output_file=./nasnet_model1.pb  --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=nasnet_large --output_file=./nasnet_model16.pb --batch_size=16
/home/mev/source/tensorflow/tensorflow-cpu/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph --in_graph=nasnet_model1.pb

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./nasnet_model1.pb \
    --input_binary=true \
    --input_checkpoint=./model.ckpt \
    --output_node_names=final_layer/predictions \
    --output_graph=./nasnet_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./nasnet_model16.pb \
    --input_binary=true \
    --input_checkpoint=./model.ckpt \
    --output_node_names=final_layer/predictions \
    --output_graph=./nasnet_i16.pb
cd ..

exit 0

cd nasnet-mobile
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=nasnet_mobile --output_file=./nasnet_model1.pb  --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=nasnet_mobile --output_file=./nasnet_model16.pb --batch_size=16
/home/mev/source/tensorflow/tensorflow-cpu/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph --in_graph=nasnet_model1.pb

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./nasnet_model1.pb \
    --input_binary=true \
    --input_checkpoint=./model.ckpt \
    --output_node_names=final_layer/predictions \
    --output_graph=./nasnet__mobile_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./nasnet_model16.pb \
    --input_binary=true \
    --input_checkpoint=./model.ckpt \
    --output_node_names=final_layer/predictions \
    --output_graph=./nasnet__mobile_i16.pb
cd ..
exit 0

cd resnet50v2
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=resnet_v2_50 --output_file=./resnet50v2_model1.pb  --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=resnet_v2_50 --output_file=./resnet50v2_model64.pb --batch_size=64
/home/mev/source/tensorflow/tensorflow-cpu/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph --in_graph=resnet50v2_model1.pb

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./resnet50v2_model1.pb \
    --input_binary=true \
    --input_checkpoint=./resnet_v2_50.ckpt \
    --output_node_names=resnet_v2_50/predictions/Reshape_1 \
    --output_graph=./resnet50v2_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./resnet50v2_model64.pb \
    --input_binary=true \
    --input_checkpoint=./resnet_v2_50.ckpt \
    --output_node_names=resnet_v2_50/predictions/Reshape_1 \
    --output_graph=./resnet50v2_i64.pb
cd ..

cd inceptionv3
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=inception_v3 --output_file=./inception_model1.pb  --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=inception_v3 --output_file=./inception_model32.pb --batch_size=32

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./inception_model1.pb \
    --input_binary=true \
    --input_checkpoint=./inception_v3.ckpt \
    --output_node_names=InceptionV3/Predictions/Reshape_1 \
    --output_graph=./inceptionv3_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./inception_model32.pb \
    --input_binary=true \
    --input_checkpoint=./inception_v3.ckpt \
    --output_node_names=InceptionV3/Predictions/Reshape_1 \
    --output_graph=./inceptionv3_i32.pb
cd ..

cd inceptionv4
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=inception_v4 --output_file=./inception_model1.pb  --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=inception_v4 --output_file=./inception_model16.pb --batch_size=16

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./inception_model1.pb \
    --input_binary=true \
    --input_checkpoint=./inception_v4.ckpt \
    --output_node_names=InceptionV4/Logits/Predictions \
    --output_graph=./inceptionv4_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./inception_model16.pb \
    --input_binary=true \
    --input_checkpoint=./inception_v4.ckpt \
    --output_node_names=InceptionV4/Logits/Predictions \
    --output_graph=./inceptionv4_i16.pb
cd ..

cd mobilenet
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=mobilenet_v1 --output_file=./mobilenet_model1.pb  --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=mobilenet_v1 --output_file=./mobilenet_model64.pb --batch_size=64
/home/mev/source/tensorflow/tensorflow-cpu/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph --in_graph=mobilenet_model1.pb

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./mobilenet_model1.pb \
    --input_binary=true \
    --input_checkpoint=./mobilenet_v1_1.0_224.ckpt \
    --output_node_names=MobilenetV1/Predictions/Reshape_1 \
    --output_graph=./mobilenet_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./mobilenet_model64.pb \
    --input_binary=true \
    --input_checkpoint=./mobilenet_v1_1.0_224.ckpt \
    --output_node_names=MobilenetV1/Predictions/Reshape_1 \
    --output_graph=./mobilenet_i64.pb
cd ..

cd resnet50v1
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=resnet_v1_50 --output_file=./resnet50v1_model1.pb  --labels_offset=1 --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=resnet_v1_50 --output_file=./resnet50v1_model64.pb --labels_offset=1 --batch_size=64
/home/mev/source/tensorflow/tensorflow-cpu/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph --in_graph=resnet50v1_model1.pb

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./resnet50v1_model1.pb \
    --input_binary=true \
    --input_checkpoint=./resnet_v1_50.ckpt \
    --output_node_names=resnet_v1_50/predictions/Reshape_1 \
    --output_graph=./resnet50v1_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./resnet50v1_model64.pb \
    --input_binary=true \
    --input_checkpoint=./resnet_v1_50.ckpt \
    --output_node_names=resnet_v1_50/predictions/Reshape_1 \
    --output_graph=./resnet50v1_i64.pb
cd ..

cd vgg
# Save the models
python3 ${SLIMDIR}/export_inference_graph.py --model_name=vgg_16 --output_file=./vgg16_model1.pb --labels_offset=1 --batch_size=1
python3 ${SLIMDIR}/export_inference_graph.py --model_name=vgg_16 --output_file=./vgg16_model16.pb --labels_offset=1 --batch_size=16

# Freeze the possible graphs
${TFCPU_FREEZE} \
    --input_graph=./vgg16_model1.pb \
    --input_binary=true \
    --input_checkpoint=./vgg_16.ckpt \
    --output_node_names=vgg_16/fc8/squeezed \
    --output_graph=./vgg16_i1.pb

${TFCPU_FREEZE} \
    --input_graph=./vgg16_model16.pb \
    --input_binary=true \
    --input_checkpoint=./vgg_16.ckpt \
    --output_node_names=vgg_16/fc8/squeezed \
    --output_graph=./vgg16_i16.pb
cd ..

exit 0
