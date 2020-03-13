# Overview
This repository contains dockerfiles, scripts and artifacts related to
AMD MIGraphX inference library.

To get started use:
   scripts/build_migraphx_docker.sh
to build a docker image including a copy of MIGraphX.  Next run the docker
image in a container with rocm-migraphx mounted (to create and save artifacts).

In this repository are the following components:

   scripts/
      build_migraphx_docker.sh - build MIGraphX docker container
      build_migraphx_docker_latest.sh - create updated MIGraphX container with latest sources.
      build_migraphx.sh - script that builds MIGraphX