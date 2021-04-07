#!/bin/bash
#
# Copyright 2019 Wind River Systems, Inc.
#
# The right to copy, distribute, modify or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#

PARAM_CONT_NAME_SUFFIX=""

source ./docker-config.sh

usage()
{
    echo ""
    echo "Usage: $(basename $0) [options]"
    echo ""
    echo "Runs a shell (/bin/bash) in an existing container."
    echo "The default ${DOCKER_CONTAINER} docker container is used unless a suffix is"
    echo "supplied using [-cont-name-suffix] option."
    echo ""
    echo "options: "
    echo "  -cont-name-suffix, -c        Container name suffix, useful for working with"
    echo "                           multiple containers"
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

DOCKER_CONTAINER=${DOCKER_CONTAINER}${PARAM_CONT_NAME_SUFFIX}

docker_running=$(docker inspect -f '{{.State.Running}}' ${DOCKER_CONTAINER})

if [ "${docker_running}" = "true" ]
then
  docker container exec -t ${DOCKER_CONTAINER} /bin/bash -c "source /usr/local/bin/set-docker-env.sh &>/dev/null"
  docker container exec -t ${DOCKER_CONTAINER} /bin/bash -c "sudo /usr/local/bin/sdk-docker-install.sh &>/dev/null"
  docker exec -it ${DOCKER_CONTAINER} /bin/bash
else
  docker start ${DOCKER_CONTAINER}
  docker container exec -t ${DOCKER_CONTAINER} /bin/bash -c "source /usr/local/bin/set-docker-env.sh &>/dev/null"
  docker container exec -t ${DOCKER_CONTAINER} /bin/bash -c "sudo /usr/local/bin/sdk-docker-install.sh &>/dev/null"
  docker attach ${DOCKER_CONTAINER}
fi
