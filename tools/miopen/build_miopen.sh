#!/bin/bash
RELEASE=${RELEASE:="release/rocm-rel-5.0"}
INSTALL_PREFIX=${INSTALL_PREFIX:=""}

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Try a few prerequisites
apt update && apt install -y python3-venv aria2 python3-pip
pip3 install wheel

NEED_CMAKE=0
if [ `which cmake \> /dev/null` ]; then
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
    apt install aria2
    aria2c -q -d /tmp -o cmake-3.21.0-linux-x86_64.tar.gz https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0-linux-x86_64.tar.gz && tar -zxf /tmp/cmake-3.21.0-linux-x86_64.tar.gz --strip=1 -C /usr
fi

exit 0

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

# Dependencies
# remove half.hpp just in case
if [ -f /usr/local/include/half.hpp ]; then rm /usr/local/include/half.hpp; fi
cmake -P install_Deps.cmake
mkdir build
cd build
if [ "$INSTALLPREFIX" != "" ]; then
    env CXX=/opt/rocm/llvm/bin/clang++ cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hip" ..
else
    env CXX=/opt/rocm/llvm/bin/clang++ cmake -DMIOPEN_BACKEND=HIP -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" -DCMAKE_PREFIX_PATH="/opt/rocm/hip" ..
fi

make
make MIOpenDriver
