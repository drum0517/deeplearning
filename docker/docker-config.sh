#set -o xtrace

BASEDIR=$(dirname $0)

SOURCE_DIR=$(readlink -f ${BASEDIR}/../../source)

DOCKER_CONTAINER=deeplearning-ubuntu18.04-linux
DOCKER_IMAGE=${DOCKER_CONTAINER}-img
