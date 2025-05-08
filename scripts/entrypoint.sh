#!/bin/bash
set -ex 
cd $(dirname $0)

CMD=$*

cp -rf /opt/yocto/conf /opt/yocto/build/
source layers/poky/oe-init-build-env /opt/yocto/build

if [ -n "$CMD" ]; then
    echo "Running $> ${CMD}"
    eval $CMD
fi
