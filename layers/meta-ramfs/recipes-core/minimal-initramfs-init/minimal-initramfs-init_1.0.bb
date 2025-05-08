SUMMARY = "Minimal initramfs initialization script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://minimal-initramfs-init.sh"

# Installs shell and binaries required for the initscript
RDEPENDS:${PN} += "${VIRTUAL-RUNTIME_base-utils}"

do_install() {
    # Install the init script itself
    install -m 0755 ${WORKDIR}/minimal-initramfs-init.sh ${D}/init
    # Kernel will panic if /dev doesn't exist
    install -d ${D}/dev
    # Required for logging to work
    mknod -m 622 ${D}/dev/console c 5 1
    # Add the mount points
    install -d ${D}/proc
    install -d ${D}/sys
    install -d ${D}/mnt
}

FILES:${PN} = "/init /dev/console /proc /sys /mnt"