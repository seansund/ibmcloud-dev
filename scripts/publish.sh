#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $0)

IMAGE_NAME="$1"
IMAGE_VER="$2"
REGISTRY_NAME="$3"

if [[ -z "${IMAGE_NAME}" ]]; then
  echo "IMAGE_NAME for the Docker image is required as the first argument"
  exit 1
fi

if [[ -z "${IMAGE_VER}" ]]; then
  echo "IMAGE_VERSION is required as the second argument"
  exit 1
fi

if [[ -z "${REGISTRY_NAME}" ]]; then
  echo "REGISTRY_NAME for Docker Registry is required as the third argument"
  exit 1
fi

if [[ -n $(docker image ls ${REGISTRY_NAME}/${IMAGE_NAME}:${IMAGE_VER}) ]]; then
  echo -e "The image \033[1;32m${REGISTRY_NAME}/${IMAGE_NAME}:${IMAGE_VER}\033[0m already exists"
  echo -en "Do you want to (o)verwrite the existing image or e(x)it? \033[1;33m[x] | o?\033[0m "
  read option
  if [[ "${option}" == "o" ]] || [[ "${option}" == "O" ]]; then
    echo -e "You chose to \033[1;31moverwrite\033[0m, proceeding with push"
  else
    echo -e "Exiting... Run \033[1;32mnpm version [option]\033[0m to update the version and initiate the push"
    exit 0
  fi
fi

${SCRIPT_DIR}/build-kube.sh ${REGISTRY_NAME} ${IMAGE_NAME} ${IMAGE_VER}
