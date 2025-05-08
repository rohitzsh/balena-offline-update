#!/bin/bash
set -e -o pipefail

cd "$(dirname "$0")"

IMAGE_NAME=balena-offline-update
VERSION=latest

if [ -z $YOCTO_ASSET_BASEDIR ]; then
    echo "YOCTO_ASSET_BASEDIR env is not defined using project root as base directory"
    YOCTO_ASSET_BASEDIR="${PWD}/.."
fi

opt="$1"

build_image() {
    echo "building yocto docker builder"
    mkdir -p .build
    cp entrypoint.sh .build
    docker build \
        --build-arg BUILDER_UID="$(id -u)" \
        --build-arg BUILDER_GID="$(id -g)" \
        -f ${PWD}/Dockerfile \
        -t ${IMAGE_NAME}:${VERSION} .build
    rm -rf .build
}

docker_cmd() {
    local cmd=$*
    echo "running yocto docker builder"
    mkdir -p "${PWD}/../build"
    mkdir -p "${YOCTO_ASSET_BASEDIR}/sstate-cache"
    mkdir -p "${YOCTO_ASSET_BASEDIR}/downloads"
    docker run --rm \
        --privileged \
        --cap-add=ALL \
        --device=/dev/kvm \
        -e BUILDER_UID="$(id -u)" \
        -e BUILDER_GID="$(id -g)" \
        --volume "${YOCTO_ASSET_BASEDIR}/sstate-cache":/opt/yocto/sstate-cache \
        --volume "${YOCTO_ASSET_BASEDIR}/downloads":/opt/yocto/downloads \
        --volume "${PWD}/../build":/opt/yocto/build \
        --volume "${PWD}/../layers":/opt/yocto/layers \
        --volume "${PWD}/../conf":/opt/yocto/conf \
        --volume /lib/modules:/lib/modules \
        --entrypoint /opt/yocto/entrypoint.sh \
        --name $IMAGE_NAME ${IMAGE_NAME}:${VERSION} \
        "$cmd"
}

docker_cmd_interactive() {
    local cmd=$*
    echo "running interactive yocto docker builder"
    mkdir -p "${PWD}/../build"
    mkdir -p "${YOCTO_ASSET_BASEDIR}/sstate-cache"
    mkdir -p "${YOCTO_ASSET_BASEDIR}/downloads"
    docker run --rm -it \
        --privileged \
        --cap-add=ALL \
        --device=/dev/kvm \
        -e BUILDER_UID="$(id -u)" \
        -e BUILDER_GID="$(id -g)" \
        --volume "${YOCTO_ASSET_BASEDIR}/sstate-cache":/opt/yocto/sstate-cache \
        --volume "${YOCTO_ASSET_BASEDIR}/downloads":/opt/yocto/downloads \
        --volume "${PWD}/../build":/opt/yocto/build \
        --volume "${PWD}/../layers":/opt/yocto/layers \
        --volume "${PWD}/../conf":/opt/yocto/conf \
        --volume /lib/modules:/lib/modules \
        --entrypoint /opt/yocto/entrypoint.sh \
        --name $IMAGE_NAME ${IMAGE_NAME}:${VERSION} \
        "$cmd"
}

clean_build() {
    rm -rf ${YOCTO_ASSET_BASEDIR}/sstate-cache
    rm -rf ${PWD}/../build
}

if [ -z "$opt" ]; then
    echo >&2 "
    Usage: ./make.sh [OPTIONS]

    Options:
        build        builds OS 
        clean        cleans build folder (except downloads and sstate-cache directory) 
        run          runs OS using qemu
        CMD          any custom command to be executed by docker container"
    exit 1
fi

case "$opt" in
"build")
    build_image
    docker_cmd bitbake balena-offline-update
    ;;
"debug")
    build_image
    docker_cmd_interactive bash
    ;;
"clean")
    clean_build
    ;;
"test")
    docker_cmd runqemu ramfs genericx86-64 nographic serial
    ;;
*)
    docker_cmd_interactive "$@"
    ;;
esac
