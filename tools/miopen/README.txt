Dockerfile and scripts for building MIOpen.

The dockerfile takes a "base_image" argument so MIOpen can be built on top of a ROCm docker
including some variation with what is installed.

There is an overall build command:
   ./build_miopen.sh

This uses four subcommands, so they can be broken into different docker steps:
   ./build_miopen_prereq.sh
   ./build_miopen_source.sh
   ./build_miopen_deps.sh
   ./build_miopen_build.sh
