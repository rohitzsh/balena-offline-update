#!/bin/bash
set -e
cd $(dirname $0)

qemu-system-x86_64 \
    -kernel ../build/tmp/deploy/images/genericx86-64/bzImage \
    -initrd ../build/tmp/deploy/images/genericx86-64/balena-offline-update-genericx86-64.cpio.gz \
    -nographic \
    -append "console=ttyS0,115200"
