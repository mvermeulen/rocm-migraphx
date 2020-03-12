#!/bin/bash
if [ ! -d tensorflow ]; then
    git clone https://github.com/tensorflow/tensorflow
else
    cd tensorflow
    git pull
    cd ..
fi
cd tensorflow
git checkout v1.13.1

