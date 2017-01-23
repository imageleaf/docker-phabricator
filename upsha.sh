#!/bin/sh

CMD=
if [ -z "$CMD" ]
then
    which curl && CMD='curl -s' && HEADER='--header '
fi
if [ -z "$CMD" ]
then
    which wget && CMD='wget -q -O-' && HEADER='--header='
fi
if [ -z "$CMD" ]
then
    >&2 echo 'curl or wget must be installed for this tool to work'
    exit 1
fi

update_sha() {
    VAR=$1
    REPO=$2
    OWNER=${3:-phacility}
    REFSPEC=${4:-stable}
    set -x
    SHA=`${CMD} "https://api.github.com/repos/${OWNER}/${REPO}/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`
    set +x
    sed -e "s/ARG ${VAR}.*/ARG ${VAR}=${SHA}/" -i Dockerfile
    echo "Variable ${VAR} set to ${SHA}"
}

update_sha PHABRICATOR_COMMIT phabricator
update_sha ARCANIST_COMMIT arcanist
update_sha LIBPHUTIL_COMMIT libphutil

echo Done, updated Dockerfile
