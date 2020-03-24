#!/bin/bash
#
# script to (re)build migx driver
if [ ! -d build ]; then
    mkdir build
fi
cd build
env CXXFLAGS=-v cmake ..
make
