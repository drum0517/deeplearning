#!/bin/bash

PARAM_CONT_NAME_SUFFIX=""

source ./docker-config.sh
usage()
{
    echo ""
    echo "Usage: $(basename $0) [options]"
    echo ""
    echo "Prepares Docker build environment:"
    echo "  1. create build and install folders"
    echo "  2. create default ${DOCKER_IMAGE} docker image if it does not exist."
    echo "  3. create ${DOCKER_CONTAINER} docker container, a container name"
    echo "     suffix can be supplied using [-cont-name-suffix] option."
    echo ""
    echo "options: "
    echo "  -cont-name-suffix, -c        Container name suffix, useful for working with"
    echo "                               multiple containers"
    echo ""
    exit 1
}

while [ $# -ne 0 ]; do
    case $1 in
        -c)
          PARAM_CONT_NAME_SUFFIX=$2
          shift
          ;;
        -cont-name-suffix)
          PARAM_CONT_NAME_SUFFIX=$2
          shift
          ;;
        -help)
          echo ""
          usage
          ;;
        *)
          usage
          ;;
    esac
shift
done
set -e
if [ "$(whoami)" == "root" ];then
  echo "*** [Error] Do not execute this script as a superuser"
  exit 1
fi

image_id=$(docker images -q ${DOCKER_IMAGE})

if [ "${image_id}" = "" ]; then
  docker build -t ${DOCKER_IMAGE} \
    --build-arg USER_NAME=$(id -un) --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_NAME=$(id -gn) --build-arg GROUP_ID=$(id -g) \
    --build-arg HOST="Linux" .
fi

DOCKER_CONTAINER=${DOCKER_CONTAINER}${PARAM_CONT_NAME_SUFFIX}

docker create -it -v ${SOURCE_DIR}:/deeplearning \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  --volume /dev/watchdog:/dev/watchdog \
  --volume /dev/watchdog0:/dev/watchdog0 \
  --security-opt seccomp=unconfined \
  --privileged \
  --name ${DOCKER_CONTAINER} ${DOCKER_IMAGE}
