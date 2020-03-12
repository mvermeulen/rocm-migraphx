#!/bin/bash
if [ ! -d tensorflow ]; then
    git clone https://github.com/tensorflow/tensorflow
    cd tensorflow
    git checkout v1.13.1
    cd ..
fi

cd tensorflow
./configure <<CMDS
/usr/bin/python3










CMDS

bazel build --jobs 4 --config=opt //tensorflow/tools/pip_package:build_pip_package
