#!/bin/bash
#
# Build MIGraphX from source
INSTALLDIR=${INSTALLDIR:="/src"}
WORKDIR=${WORKDIR:="/workdir"}
GPU_TARGETS=${GPU_TARGETS:="gfx906;gfx1030"}

pip3 install https://github.com/RadeonOpenCompute/rbuild/archive/master.tar.gz
mkdir -p ${INSTALLDIR}
cd ${INSTALLDIR}
git clone --depth=1 https://github.com/ROCm/AMDMIGraphX
cd AMDMIGraphX
rbuild package --cxx /opt/rocm/llvm/bin/clang++ -d ${INSTALLDIR}/AMDMIGraphX/depend -B ${INSTALLDIR}/AMDMIGraphX/build -DGPU_TARGETS=${GPU_TARGETS}
cd build
dpkg -i *.deb

