#!/bin/bash
#
# Turn perf report output for resnet 50 into CSV list
fgrep conv $1 | grep ms | grep main | sed -e 's/\[.*\]//g' -e 's/(.*)//g' -e 's/->.*:/,/g' -e 's/=/,/g' -e 's/ms//g'
