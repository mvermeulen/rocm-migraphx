#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
CACHE=${CACHE:="--no-cache"}
docker build $CACHE -f dockerfile-nvidia -t ort:cuda-${DATESTAMP} .
