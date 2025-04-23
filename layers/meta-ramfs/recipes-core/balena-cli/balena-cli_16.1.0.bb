SUMMARY = "Minimal initramfs initialization script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "https://git.sr.ht/~rohitzsh/balena-cli/refs/download/v${PV}/balena-v${PV}.zip;md5sum=6f7831520376217b745c4f9a366675d9"

do_install() {
    install -d ${D}/opt/balena-cli
    install -m 755 ${WORKDIR}/balena ${D}/opt/balena-cli/
}

INSANE_SKIP:${PN} += "already-stripped"

FILES:${PN} = "/opt/balena-cli/*"