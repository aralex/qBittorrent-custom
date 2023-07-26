#!/bin/bash

set -e

CMD=$1

CUR_DIR=`realpath $(dirname "$0")`

IMAGE='opensuse_leap-dev:15.5'

CONTAINER_NAME=$(realpath . | cut -c 2- | tr ' /' '.')

echo "Docker base image:  $IMAGE"
echo "Docker container:   $CONTAINER_NAME"


if [[ -z $CMD ]]
then
    echo "Usage: $0 (build|stop|run)"
    exit
fi


function show_n_exec() {
    echo "\$ $@" ;
    "$@"
}


function is_container_running() {
    local container_name=$1
    docker ps -a -f name="^$container_name\$" -f status=running -q
}


function destroy_container() {
    local container_name=$1

    # Если контейнер запущен, завершаем его.
    [[ -z $(is_container_running "$container_name") ]] || show_n_exec docker kill $container_name

    # Если контейнер существует, удаляем его.
    [[ -z $(docker ps -a -f name="^$container_name\$" -q) ]] || show_n_exec docker rm $container_name
}


GID=`id -g`
GROUP=`id -n -g`

TMP_DIR='./tmp'

[[ -d $TMP_DIR ]] && rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

case $CMD in
    build)
        echo "Build Docker image ${IMAGE}"
        destroy_container "${CONTAINER_NAME}"
        show_n_exec docker build --network=host -t ${IMAGE} -f ./Dockerfile.openSUSE-15 "$TMP_DIR"
        rm -rf "$TMP_DIR"
        ;;

    stop)
        echo "Stop Docker CONTAINER_NAME=${CONTAINER_NAME}"
        destroy_container "${CONTAINER_NAME}"
        ;;

    run)
        echo "Run Docker IMAGE=${IMAGE} CONTAINER_NAME=${CONTAINER_NAME}"

        if ! [[ $(is_container_running "${CONTAINER_NAME}") ]]
        then
            show_n_exec docker run \
                --net=host \
                --pid=host \
                --ipc=host \
                --workdir="$CUR_DIR" \
                --name="$CONTAINER_NAME" \
                -v "$CUR_DIR":"$CUR_DIR" \
                -v $HOME/.bash_history:$HOME/.bash_history \
                -v $HOME/.gitconfig:$HOME/.gitconfig \
                -d "${IMAGE}" \
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
        fi

        show_n_exec docker exec -it "$CONTAINER_NAME" /bin/bash -c "su -P -c '/bin/bash -l' $USER"
        ;;
esac
