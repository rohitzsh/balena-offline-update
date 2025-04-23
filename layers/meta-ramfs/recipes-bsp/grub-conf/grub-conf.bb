SUMMARY = "Grub configuration file"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://grub.cfg \
           file://grub-early.cfg "

GRUBPLATFORM = "efi"
GRUB_TARGET = "x86_64"
IMAGE_INSTALL += " grub-efi"
DEPENDS += " grub-efi grub-native"

do_compile() {
    sed -e "s/@@INITRAMFS_IMAGE@@/balena-offline-update-genericx86-64/g" \
        "${WORKDIR}/grub.cfg" > "${B}/grub.cfg"
    install -m 644 ${WORKDIR}/grub-early.cfg ${B}/

    grub-mkimage -O x86_64-efi -o ${B}/BOOTX64.EFI \
        -p /EFI/BOOT \
        -c ${WORKDIR}/grub-early.cfg \
        -d ${STAGING_LIBDIR}/grub/x86_64-efi \
        fat part_gpt normal configfile cpio gzio terminal serial search part_msdos ext2 linux search_fs_file search_fs_uuid search_label
}

do_install[noexec] = '1'

do_deploy() {
    install -d ${DEPLOY_DIR_IMAGE}
    install -m 644 ${B}/grub.cfg ${DEPLOY_DIR_IMAGE}
    install -m 644 ${B}/grub-early.cfg ${DEPLOY_DIR_IMAGE}
    install -m 644 ${B}/BOOTX64.EFI ${DEPLOY_DIR_IMAGE}
}

addtask do_deploy before do_package after do_install
