#!/bin/bash
##
# Copyright (c) New Cloud Technologies, Ltd., 2014-2022
#
# You can not use the contents of the file in any way without
# New Cloud Technologies, Ltd. written permission.
#
# To obtain such a permit, you should contact New Cloud Technologies, Ltd.
# at http://ncloudtech.com/contact.html
#
##

set -e

CMD=$1

CUR_DIR=`realpath $(dirname "$0")`

BASE_IMAGE='opensuse_leap-dev:15.5'

CONTAINER_NAME=$(realpath . | cut -c 2- | tr ' /' '.')

echo "Docker base image:  $BASE_IMAGE"
echo "Docker container:   $CONTAINER_NAME"

function usage {
    echo "Usage:"
    echo "       $1 build"
    echo "       $1 run"
    echo "       $1 stop"
    echo "       $1 restart"
    exit
}

function show_n_exec() {
    echo "\$ $@" ;
    "$@"
}

kill_rm_container_by_name() {
  if [ ! -z $(docker ps -a -f name="$1\$" -f status=running -q) ]; then
    show_n_exec docker kill $1
  fi

  if [ ! -z $(docker ps -a -f name="$1\$" -q) ]; then
    show_n_exec docker rm $1
  fi
}

GID=`id -g`
GROUP=`id -n -g`

TMP_DIR='./tmp'

[[ -d $TMP_DIR ]] && rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

case $CMD in
    build)
        echo "Build docker image ${BASE_IMAGE}"
        #    kill_rm_container_by_name ${CONTAINER_NAME}
        show_n_exec docker build --network=host -t ${BASE_IMAGE} -f ./Dockerfile.openSUSE-15 "$TMP_DIR"
        ;;

    stop)
        echo "stop docker CONTAINER_NAME=${CONTAINER_NAME}"
        #    kill_rm_container_by_name ${CONTAINER_NAME}
        ;;

    run)
        #    docker pull ${IMAGE}
        echo "run docker IMAGE=${IMAGE} CONTAINER_NAME=${CONTAINER_NAME}"

        show_n_exec docker run \
            --net=host \
            --pid=host \
            --ipc=host \
            --workdir="$CUR_DIR" \
            --name="$CONTAINER_NAME" \
            -v "$CUR_DIR":"$CUR_DIR" \
            -v $HOME/.bash_history:$HOME/.bash_history \
            -v $HOME/.gitconfig:$HOME/.gitconfig \
            -d "${BASE_IMAGE}" \
            sleep infinity

        # Создаём в контейнере пользователя, идентичного (в разумной мере) текущему пользователю хост-системы.
        show_n_exec docker exec -it "$CONTAINER_NAME" /bin/bash -c " \
            set -e -v -x && \
            groupadd -f -g $GID $GROUP && \
            echo export PS1=\\'\\\\u@[openSUSE - \\\\w] \\\\$ \\' >>/home/$USER/.profile "' && \
            echo export PATH=\"$PATH:\$PATH\"'" >>/home/$USER/.profile && \
            useradd -u $UID -g $GID $USER && \
            chown $USER:$GROUP /home/$USER && \
            echo '$USER ALL=(ALL:ALL) NOPASSWD:ALL' >/etc/sudoers.d/$USER"

        show_n_exec docker exec -it "$CONTAINER_NAME" /bin/bash -c "su -P -c '/bin/bash -l' $USER"
        ;;
esac
