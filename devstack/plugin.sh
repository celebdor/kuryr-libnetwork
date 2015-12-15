#!/bin/bash
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set +o xtrace

ETCD_VERSION=v2.2.2

function install_etcd_data_store {

    if [ ! -f "$DEST/etcd/etcd-$ETCD_VERSION-linux-amd64/etcd" ]; then
        echo "Installing etcd server"
        mkdir $DEST/etcd
        wget https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz -O $DEST/etcd/etcd-$ETCD_VERSION-linux-amd64.tar.gz
        tar xzvf $DEST/etcd/etcd-$ETCD_VERSION-linux-amd64.tar.gz -C $DEST/etcd
    fi

    # Clean previous DB data
    rm -rf $DEST/etcd/db.etcd
}

# main loop
if is_service_enabled kuryr; then
    if [[ "$1" == "stack" && "$2" == "install" ]]; then
        install_etcd_data_store
        setup_develop $KURYR_HOME

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then

        if [[ ! -d "${KURYR_JSON_DIR}" ]]; then
            echo -n "${KURYR_JSON_DIR} directory is missing. Creating it... "
            sudo mkdir -p ${KURYR_JSON_DIR}
            echo "Done"
        fi

        if [[ ! -f "${KURYR_JSON}" ]]; then
             echo -n "${KURYR_JSON} is missing. Copying the default one... "
             sudo cp ${KURYR_DEFAULT_JSON} ${KURYR_JSON}
             echo "Done"
        fi

        if [[ ! -d "${KURYR_CONFIG_DIR}" ]]; then
            echo -n "${KURYR_CONFIG_DIR} directory is missing. Creating it... "
            sudo mkdir -p ${KURYR_CONFIG_DIR}
            echo "Done"
        fi

        if [[ ! -f "${KURYR_CONFIG}" ]]; then
            if [[ -f "${KURYR_DEFAULT_CONFIG}" ]]; then
                echo -n "${KURYR_CONFIG} is missing. Copying the default one... "
                sudo cp ${KURYR_DEFAULT_CONFIG} ${KURYR_CONFIG}
                echo "Done"
            else
                echo -n "${KURYR_CONFIG} and the  default config missing. Auto generating and copying one... "
                cd ${KURYR_HOME}
                tox -egenconfig
                sudo cp ${KURYR_DEFAULT_CONFIG}.sample ${KURYR_DEFAULT_CONFIG}
                sudo cp ${KURYR_DEFAULT_CONFIG} ${KURYR_CONFIG}
                cd -
            fi
        fi

        # Delete previous etcd data first
        run_process etcd-server "$DEST/etcd/etcd-$ETCD_VERSION-linux-amd64/etcd --data-dir $DEST/etcd/db.etcd"

        wget http://get.docker.com -O install_docker.sh
        sudo chmod 777 install_docker.sh
        sudo sh install_docker.sh
        sudo rm install_docker.sh

        sudo killall docker
        run_process docker-engine "sudo /usr/bin/docker daemon --cluster-store etcd://localhost:4001"
        run_process kuryr "sudo PYTHONPATH=$PYTHONPATH:$DEST/kuryr SERVICE_USER=admin SERVICE_PASSWORD=$SERVICE_PASSWORD SERVICE_TENANT_NAME=admin SERVICE_TOKEN=$SERVICE_TOKEN IDENTITY_URL=http://127.0.0.1:5000/v2.0 python $DEST/kuryr/scripts/run_server.py  --config-file /etc/kuryr/kuryr.conf"
    fi

    if [[ "$1" == "unstack" ]]; then
        stop_process kuryr
        stop_process etcd-server
        stop_process docker-engine
    fi
fi

# Restore xtrace
$XTRACE
