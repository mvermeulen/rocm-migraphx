#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
CACHE=${CACHE:="--no-cache"}
diff dockerfile-rocm ../../dockerfiles/dockerfile-ort
docker build ${CACHE} -f dockerfile-rocm -t ort:migraphx-${DATESTAMP} .
