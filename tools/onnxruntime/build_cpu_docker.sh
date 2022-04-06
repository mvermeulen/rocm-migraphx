#!/bin/bash
DATESTAMP=`date '+%Y%m%d'`
CACHE=${CACHE:="--no-cache"}
docker build $CACHE -f dockerfile-cpu -t ort:cpu-${DATESTAMP} .
