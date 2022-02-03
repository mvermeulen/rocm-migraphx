#!/bin/bash
#
# File to install prequisite requirements
#
# This could be installed on top of almost any environment, so work to get key pre-requisites
# Most of them are benign if reinstalled, a few such as "cmake" or "half" we check before
# reinstalling
apt update && apt install -y python3-venv python3-pip git rocblas pkg-config
pip3 install wheel

NEED_CMAKE=0
cmake_count=`which cmake | wc -l`
if [ "$cmake_count" == 0 ]; then
    NEED_CMAKE=1
else
    version=`cmake --version | head -1 | awk '{ print $3 }'`
    if [ $version \> "3.15" ]; then
	echo "cmake version $version"
    else
	NEED_CMAKE=1
    fi
fi

if [ "$NEED_CMAKE" != "0" ]; then
    apt install -y aria2
    aria2c -q -d /tmp -o cmake-3.21.0-linux-x86_64.tar.gz https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0-linux-x86_64.tar.gz && tar -zxf /tmp/cmake-3.21.0-linux-x86_64.tar.gz --strip=1 -C /usr
fi
