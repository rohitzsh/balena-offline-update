SUMMARY = "Basic initramfs"
DESCRIPTION = "Small initramfs that contains init"
LICENSE = "MIT"

require conf/machine/include/genericx86-common.inc
EXTRA_PACKAGES = "\
                    base-passwd \
                    parted \
                    file \
                    e2fsprogs-mke2fs \
                    util-linux-lsblk \
"

PACKAGE_INSTALL = "${VIRTUAL-RUNTIME_base-utils} ${EXTRA_PACKAGES} busybox minimal-initramfs-init"

# Ensure the initramfs only contains the bare minimum
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_INSTALL += " grub-efi grub-conf"


PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_FSTYPES:append = " cpio.gz usbimg"

ROOTFS_POSTPROCESS_COMMAND += "setup_data_partition;"

setup_data_partition() {
    mkdir -p ${IMAGE_ROOTFS}/data
    echo "LABEL=datafs /data ext4 defaults 0 0" >> ${IMAGE_ROOTFS}/etc/fstab
    install -d ${IMAGE_ROOTFS}/proc
    install -d ${IMAGE_ROOTFS}/sys
    install -d ${IMAGE_ROOTFS}/mnt
}

IMAGE_NAME_SUFFIX ?= ""
IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "10"

inherit image
