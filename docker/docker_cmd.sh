# 
# File: docker_cmd.sh
# 
# Copyright 2004-2018 Adaptive Insights, Inc.
# All Rights Reserved.
#
# This work contains trade secrets and confidential material of
# Adaptive Insights, Inc., and its use or disclosure in whole or in part
# without the express written permission of Adaptive Insights, Inc. is prohibited.
#

alias dk=docker
alias dkr='function __dkr() { docker run -it $1 sh; }; __dkr'
alias dke='function __dke() { docker exec -it $1 sh; }; __dke'
alias dkl='function __dkl() { docker logs -ft $1 ; }; __dkl'

alias dkpsf='function __dkpsf() { docker ps -f "name=${1}" ; }; __dkpsf'

function build_docker_image () {
  local IM_NAME
  local IM_TAG
  [ -z $DOCKER_IM_NAME ] || IM_NAME=$DOCKER_IM_NAME
  [ -z $DOCKER_IM_TAG ] || IM_TAG=$DOCKER_IM_TAG

  local BUILD_ARGS="--no-cache"
  [[ -z $POC_RELEASE_BR ]] || BUILD_ARGS=$BUILD_ARGS" --build-arg POC_RELEASE_BR=$POC_RELEASE_BR "

  docker build -t $IM_NAME:$IM_TAG $BUILD_ARGS .
  return 0
}

function push_docker_image() {
  local REPO_URL
  local REPO_USER
  local REPO_PWD
  local IM_NAME=centos7-utilities
  local IM_TAG=latest
  [ -z $DOCKER_IM_NAME ] || IM_NAME=$DOCKER_IM_NAME
  [ -z $DOCKER_IM_TAG ] || IM_TAG=$DOCKER_IM_TAG

  [ -z $DOCKER_REPO_URL ] || REPO_URL=$DOCKER_REPO_URL
  [ -z $DOCKER_REPO_USER ] || REPO_USER=$DOCKER_REPO_USER
  [ -z $DOCKER_REPO_PWD ] || REPO_PWD=$DOCKER_REPO_PWD

  docker login $REPO_URL -u $REPO_USER -p $REPO_PWD
  docker push $IM_NAME:$IM_TAG
  return 0
}

function dockerize() {
  build_docker_image $@
  push_docker_image $@
}

function docker_cleanup_all_containers(){
  ##  To do: get a confirmation before forcely rm containers
  [[ -z $1 ]] && docker rm $(docker ps -a -q) \
              || docker rm -f $(docker ps -a -q)

  return $?
}

function docker_rm_incompleted_images(){
  [[ -z $1 ]] &&  docker rmi $(docker images | grep none | awk '{print $3}') \
              || docker rmi -f $(docker images | grep none | awk '{print $3}')

  return $?
}
