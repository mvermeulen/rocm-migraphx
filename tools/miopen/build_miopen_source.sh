#!/bin/bash
RELEASE=${RELEASE:="release/rocm-rel-5.0"}

if [ -d MIOpen ]; then
    echo "MIOpen found, updating repository"
    cd MIOPen
    git pull
    cd ..
else
    echo "MIOpen not found, cloning repository"
    git clone https://github.com/ROCmSoftwarePlatform/MIOpen
fi

cd MIOpen
git checkout $RELEASE
