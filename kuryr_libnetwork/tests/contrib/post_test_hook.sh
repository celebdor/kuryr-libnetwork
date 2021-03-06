#!/usr/bin/env bash

set -xe

KURYR_LIBNETWORK_DIR="$BASE/new/kuryr-libnetwork"
TEMPEST_DIR="$BASE/new/tempest"
SCRIPTS_DIR="/usr/os-testr-env/bin/"

venv=${1:-"fullstack"}

function generate_test_logs {
    local path="$1"
    # Compress all $path/*.txt files and move the directories holding those
    # files to /opt/stack/logs. Files with .log suffix have their
    # suffix changed to .txt (so browsers will know to open the compressed
    # files and not download them).
    if [[ -d "$path" ]] ; then
        sudo find "$path" -iname "*.log" -type f -exec mv {} {}.txt \; -exec gzip -9 {}.txt \;
        sudo mv "$path/*" /opt/stack/logs/
    fi
}

function generate_testr_results {
    # Give job user rights to access tox logs
    sudo -H -u "$owner" chmod o+rw .
    sudo -H -u "$owner" chmod o+rw -R .testrepository
    if [[ -f ".testrepository/0" ]] ; then
        ".tox/$venv/bin/subunit-1to2" < .testrepository/0 > ./testrepository.subunit
        $SCRIPTS_DIR/subunit2html ./testrepository.subunit testr_results.html
        gzip -9 ./testrepository.subunit
        gzip -9 ./testr_results.html
        sudo mv ./*.gz /opt/stack/logs/
    fi

    if [[ "$venv" == fullstack* ]] ; then
        generate_test_logs "/tmp/${venv}-logs"
    fi
}

#owner=tempest
# Configure the api tests to use the tempest.conf set by devstack.
#sudo_env="TEMPEST_CONFIG_DIR=$TEMPEST_DIR/etc"

owner=stack
sudo_env=

# Set owner permissions according to job's requirements.
cd "$KURYR_LIBNETWORK_DIR"
sudo chown -R $owner:stack "$KURYR_LIBNETWORK_DIR"

# Run tests
echo "Running Kuryr $venv tests"
set +e
sudo -H -u "$owner" tox -e "$venv"
testr_exit_code=$?
set -e

# Collect and parse results
generate_testr_results
exit $testr_exit_code
