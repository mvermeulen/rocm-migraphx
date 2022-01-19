#!/bin/bash
#
# Find MIOpen driver commands for convolution from a stderr logfile
#
OUTFILE=${OUTFILE:="convolutions.log"}

fgrep LogCmdConvolution $* | awk '{ $1=""; $2=""; $3=""; print $0 }' | sort -u | tee $OUTFILE
