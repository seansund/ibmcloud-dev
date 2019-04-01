#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $0)

IMAGE_NAME="$1"
IMAGE_VERSION="$2"
REGISTRY_NAME="$3"

if [[ -z "${IMAGE_NAME}" ]]; then
  echo "IMAGE_NAME for the Docker image is required as the first argument"
  exit 1
fi

if [[ -z "${IMAGE_VERSION}" ]]; then
  echo "IMAGE_VERSION is required as the second argument"
  exit 1
fi

if [[ -z "${REGISTRY_NAME}" ]]; then
  echo "REGISTRY_NAME for Docker Registry is required as the third argument"
  exit 1
fi

${SCRIPT_DIR}/build-kube.sh ${REGISTRY_NAME} ${IMAGE_NAME} ${IMAGE_VERSION}
