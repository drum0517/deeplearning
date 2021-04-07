#!/bin/bash
# Author : Jay Lee
# E-Mail : jaewon.lee@hyundai-autron.com
# Last-Edit : 02 Dec, 2020

# Modification History
# 1 Sep, 2020  | First Commit
# 24 Sep, 2020 | Bug fix in case of cleaning All
# 14 Oct, 2020 | Bug fix in case of cleaning Target
# 16 Oct, 2020 | Bug fix in case of cleaning
# 02 Nov, 2020 | Bug fix in case of cleaning Target
# 02 Dec, 2020 | Modify Default Mode


PARAM_CONT_NAME_SUFFIX=""
VERBOSE_STRING="&>/dev/null"
BASE_PATH=$(readlink -f $(dirname $0))
source $BASE_PATH/docker-config.sh
FORCED_STRING=""
IS_CLEAR_CONTAINER_ONLY="TRUE"

usage()
{
  echo \
"*****************************************************************
    Options
    $0 -h       : Show usage
    $0 -a       : Clean All including $DOCKER_IMAGE and $DOCKER_CONTAINER
    $0 -c       : Clean All including $DOCKER_CONTAINER Only (except image) (Default)
    $0 -f       : Enable forced delete 
    $0 -t       : Clean Target
    $0 -l       : Show Lists related to $DOCKER_CONTAINER
    $0 -v       : Enable Verbose mode
*****************************************************************"
  exit 0
}
LISTS=("ALL")
TARGET="ALL"
count=0
get_lists(){
    for line in $(eval docker ps -a | grep $DOCKER_CONTAINER | awk '{print $NF}')
    do 
      LISTS+=("$line")
      count=`expr $count + 1`
    done
    if [ $count -eq 0 ];then
      echo "*** Docker container related to $DOCKER_CONTAINER dosen't exist.."
      exit 0
    fi
}

show_lists(){
  get_lists
  echo "*** Show Lists releated to $DOCKER_CONTAINER-img"
  for line in ${LISTS[@]}
  do echo "  * "$line
  done
  exit 1
}

clean_target(){
  if [ "$TARGET" == "ALL" ];then
    echo "*** Clean ALL!"
    get_lists
    for line in ${LISTS[@]}
    do
      if [ "$line" == "ALL" ];then continue; fi
      echo "*** Remove $line"
      docker rm $FORCED_STRING $line
    done
    
    if [ "$IS_CLEAR_CONTAINER_ONLY" == "FALSE" ];then
      echo "*** Remove Image $DOCKER_IMAGE"
      docker rmi $FORCED_STRING $DOCKER_IMAGE $VERBOSE_STRING
    fi  
    
  else
      echo "*** Remove $TARGET"
      docker rm $FORCED_STRING $TARGET
  fi
  echo "*** Clean Done"
  exit 0
}

check_target(){
  get_lists
  FOUND=""
  for line in ${LISTS[@]}
  do
    if [ "$line" == "$TARGET" ];then
      FOUND="TRUE"; break
    fi
  done
  if [ "$FOUND" == "" ];then
    echo "*** [Error] $TARGET dosen't exits in lists.."
    show_lists
  fi 
}

while getopts "acflhvt:" setup_flag
do
  case $setup_flag in
    a)
      echo "*** Remove Containers and except image"
      IS_CLEAR_CONTAINER_ONLY="FALSE"
      TARGET="ALL";;
    c)
      echo "*** Remove Containers only (except image)"
      IS_CLEAR_CONTAINER_ONLY="TRUE";;
    f)
      FORCED_STRING="-f";;
    l)
      show_lists;;
    h)
      usage;;
    v)
      set -x
      VERBOSE_STRING="";;
    t)
      TARGET=$OPTARG
      check_target;;
  esac
done

clean_target
exit 0