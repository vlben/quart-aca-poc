#!/usr/bin/env bash

set -e

IMAGE_NAME = $1

if [ -z "$IMAGE_NAME" ]; then
    echo "Please specify the docker image name."
    exit 1
fi

build_image() {
    local cwd = "poc"

    docker build -t $IMAGE_NAME $cwd --network=host
}

if [ -f "poc/Dockerfile" ]; then
    build_image
else
    echo "No dockerfile found."
    exit 1
fi
