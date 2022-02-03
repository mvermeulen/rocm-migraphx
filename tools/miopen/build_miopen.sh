#!/bin/bash
RELEASE=${RELEASE:="release/rocm-rel-5.0"}
INSTALL_PREFIX=${INSTALL_PREFIX:=""}

# Build of MIOpen broken into four subfiles (so they can individually pass/fail in docker)

./build_miopen_prereq.sh
./build_miopen_source.sh
./build_miopen_deps.sh
./build_miopen_build.sh
