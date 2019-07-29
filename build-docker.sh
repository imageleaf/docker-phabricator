#!/bin/sh

CMD=
if [ -z "$CMD" ]; then
    which curl && CMD='curl -s' && HEADER='--header '
fi
if [ -z "$CMD" ]; then
    which wget && CMD='wget -q -O-' && HEADER='--header='
fi
if [ -z "$CMD" ]; then
    >&2 echo 'curl or wget must be installed for this tool to work'
    exit 1
fi

OWNER=${1:-phacility}
REFSPEC=${2:-stable}

export PHABRICATOR_COMMIT=`${CMD} "https://api.github.com/repos/${OWNER}/phabricator/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`
export ARCANIST_COMMIT=`${CMD} "https://api.github.com/repos/${OWNER}/arcanist/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`
export LIBPHUTIL_COMMIT=`${CMD} "https://api.github.com/repos/${OWNER}/libphutil/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`

echo Done, updated Dockerfile

docker build \
    --build-arg PHABRICATOR_COMMIT=${PHABRICATOR_COMMIT} \
    --build-arg ARCANIST_COMMIT=${ARCANIST_COMMIT} \
    --build-arg LIBPHUTIL_COMMIT=${LIBPHUTIL_COMMIT} \
    -t imageleaf/phabricator:stable .
(cd database && docker build --build-arg PHABRICATOR_COMMIT=${PHABRICATOR_COMMIT} -t imageleaf/phabricator-mysql:stable .)
