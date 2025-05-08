#!/bin/bash
set -e -o pipefail

cd "$(dirname "$0")"

IMAGE_NAME=balena-offline-update
VERSION=latest

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
    docker run --rm \
        --privileged \
        --cap-add=ALL \
        --device=/dev/kvm \
        -e BUILDER_UID="$(id -u)" \
        -e BUILDER_GID="$(id -g)" \
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
    docker run --rm -it \
        --privileged \
        --cap-add=ALL \
        --device=/dev/kvm \
        -e BUILDER_UID="$(id -u)" \
        -e BUILDER_GID="$(id -g)" \
        --volume "${PWD}/../build":/opt/yocto/build \
        --volume "${PWD}/../layers":/opt/yocto/layers \
        --volume "${PWD}/../conf":/opt/yocto/conf \
        --volume /lib/modules:/lib/modules \
        --entrypoint /opt/yocto/entrypoint.sh \
        --name $IMAGE_NAME ${IMAGE_NAME}:${VERSION} \
        "$cmd"
}

clean_build() {
    for item in build/*; do
        if [[ ! "$item" =~ (downloads) ]]; then
            rm -rf "$item"
        fi
    done
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
