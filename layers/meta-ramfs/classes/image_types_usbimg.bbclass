# Custom USB image class that creates a bootable .img file
inherit image_types

USB_BOOT_SIZE_MB = "128"
USB_IMAGE_EXTRA_SPACE = "10"

# Required native tools
DEPENDS += " \
    grub-efi-native \
    grub-native \
    parted-native \
    mtools-native \
    util-linux-native \
    cpio-native \
    grub-efi \
    e2fsprogs \
"

do_image_usbimg[depends] += "${PN}:do_image_cpio"
do_image_usbimg[depends] += "grub-conf:do_deploy"
do_image_usbimg[depends] += "virtual/kernel:do_deploy"

INITRAMFS_IMAGE = "balena-offline-update-genericx86-64"
KERNEL_INITRAMFS = "-initramfs"
KERNEL_IMAGETYPE ?= "bzImage"

# Main image creation task
IMAGE_CMD:usbimg() {

    rm -rf ${DEPLOY_DIR_IMAGE}/*.usbimg
    IMG_NAME="${IMAGE_NAME}.usbimg"
    IMG_PATH="${DEPLOY_DIR_IMAGE}/${IMG_NAME}"
    WORKDIR="${WORKDIR}/usbimg"

    mkdir -p "${WORKDIR}"
    cd "${WORKDIR}"

    truncate -s1G "${IMG_PATH}"

    parted --script "${IMG_PATH}" mklabel gpt
    parted --script "${IMG_PATH}" mkpart primary fat32 1MiB ${USB_BOOT_SIZE_MB}MiB
    parted --script "${IMG_PATH}" mkpart primary ext4 ${USB_BOOT_SIZE_MB}MiB 100%
    parted --script "${IMG_PATH}" set 1 boot on
    parted --script "${IMG_PATH}" set 1 esp on
    parted --script "${IMG_PATH}" name 1 boot
    parted --script "${IMG_PATH}" name 2 datafs
    
    parted "${IMG_PATH}" unit s print
    mformat -i "${IMG_PATH}@@2048s" -F ::

    mkfs.ext4 \
        -F \
        -L datafs \
        -E offset=134217728 \
        -b 4096 \
        "${IMG_PATH}" \
        229120

    parted "${IMG_PATH}" unit s print

    install -d EFI/BOOT
    install -m 644 "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}" EFI/BOOT
    install -m 644 "${WORKDIR}/deploy-${PN}-image-complete/${INITRAMFS_IMAGE}.cpio.gz" EFI/BOOT
    install -m 644 "${DEPLOY_DIR_IMAGE}/grub.cfg" EFI/BOOT
    install -m 644 "${DEPLOY_DIR_IMAGE}/grub-early.cfg" EFI/BOOT
    install -m 644 "${DEPLOY_DIR_IMAGE}/BOOTX64.EFI" EFI/BOOT

    mcopy -i "${IMG_PATH}@@2048s" -s EFI ::/

    install ${IMG_PATH} ${IMGDEPLOYDIR}/${PN}-${MACHINE}.usbimg
}

