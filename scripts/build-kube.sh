#!/usr/bin/env bash

REGISTRY_NAME=$1
IMAGE_NAME=$2
IMAGE_VER=$3

if [[ -z "${REGISTRY_NAME}" ]] || [[ -z "${IMAGE_NAME}" ]] || [[ -z "${IMAGE_VER}" ]]; then
  echo "Usage: ./build_kube.sh {REGISTRY_NAME} {IMAGE_NAME} {IMAGE_VER}"
  exit 1
fi

docker build -t ${REGISTRY_NAME}/${IMAGE_NAME}:${IMAGE_VER} -t ${REGISTRY_NAME}/${IMAGE_NAME}:latest .

docker push ${REGISTRY_NAME}/${IMAGE_NAME}:${IMAGE_VER}
docker push ${REGISTRY_NAME}/${IMAGE_NAME}:latest
