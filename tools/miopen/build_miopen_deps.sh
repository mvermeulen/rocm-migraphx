#!/bin/bash
cd MIOpen

# Dependencies
# remove half.hpp just in case
if [ -f /usr/local/include/half.hpp ]; then rm /usr/local/include/half.hpp; fi
cmake -P install_deps.cmake

