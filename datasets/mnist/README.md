MNIST dataset, downloaded from the web.

In this directory are the following files:
   ./download.sh - script to download the MNIST data files for test/train image\
s and labels
   ./mnist_image0.txt - mnist test image #0 - label=7
   ./mnist_image1.txt - mnist test image #1 - label=2
   ./mnist_image2.txt - mnist test image #2 - label=1
   ./mnist_image3.txt - mnist test image #3 - label=0
   ./mnist_image4.txt - mnist test image #4 - label=4
   ./mnist_image5.txt - mnist test image #5 - label=1
   ./mnist_image6.txt - mnist test image #6 - label=4
   ./mnist_image7.txt - mnist test image #7 - label=9
   ./mnist_image8.txt - mnist test image #8 - label=5
   ./mnist_image9.txt - mnist test image #9 - label=9

A few examples using the migx driver with files in this directory

# evaluate one mnist image
prompt% cd migraphx_sample/migraphx_driver/build
prompt% ./migx --tfpb ../../tfpb/frozen_mnist.pb --argname=flatten_input --debu\
gfile ../../mnist/mnist_image0.txt --eval

# evaluate all mnist images to compute pass rate
prompt% cd migraphx_sample/migraphx_driver/build
prompt% ./migx --tfpb ../../tfpb/frozen_mnist.pb --argname=flatten_input --mnis\
t ../../mnist

# evaluate all mnist images with verbose to show labels
prompt% cd migraphx_sample/migraphx_driver/build
prompt% ./migx --tfpb ../../tfpb/frozen_mnist.pb --argname=flatten_input --mnis\
t ../../mnist --verbose
