#!/bin/bash

VERSION=${1:-dev}
REFSPEC=${2:-stable}
OWNER=${3:-phacility}

PERSISTENT_FILE="persistent-${OWNER}-${REFSPEC}.env"

if [[ ! -f "${PERSISTENT_FILE}" ]]; then
    CMD=
    if [[ -z "$CMD" ]]; then
        (which curl > /dev/null) && CMD='curl -s' && HEADER='--header '
        echo "Using curl"
    fi
    if [[ -z "$CMD" ]]; then
        (which wget > /dev/null) && CMD='wget -q -O-' && HEADER='--header='
        echo "Using wget"
    fi
    if [[ -z "$CMD" ]]; then
        >&2 echo 'curl or wget must be installed for this tool to work'
        exit 1
    fi
    export PHABRICATOR_COMMIT=`${CMD} "https://api.github.com/repos/${OWNER}/phabricator/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`
    export ARCANIST_COMMIT=`${CMD} "https://api.github.com/repos/${OWNER}/arcanist/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`
    export LIBPHUTIL_COMMIT=`${CMD} "https://api.github.com/repos/${OWNER}/libphutil/commits/${REFSPEC}" ${HEADER}"Accept: application/vnd.github.v3.sha"`
    PERSISTENT_ENV=$(cat <<EOF
export PHABRICATOR_COMMIT=${PHABRICATOR_COMMIT}
export ARCANIST_COMMIT=${ARCANIST_COMMIT}
export LIBPHUTIL_COMMIT=${LIBPHUTIL_COMMIT}
EOF
)
    echo "${PERSISTENT_ENV}" > "${PERSISTENT_FILE}"
    echo "Using variables from repository, saving to file ${PERSISTENT_FILE}"
else
    source "${PERSISTENT_FILE}"
    echo "Using variables from file ${PERSISTENT_FILE}"
fi

echo "Variables:"
echo "PHABRICATOR_COMMIT=${PHABRICATOR_COMMIT}"

echo "Got it, building database docker images"

(cd database && docker build --build-arg PHABRICATOR_COMMIT=${PHABRICATOR_COMMIT} -t "imageleaf/phabricator-mysql:${REFSPEC}" .)

if [[ "$VERSION" != "dev" ]]; then
    docker tag "imageleaf/phabricator-mysql:${REFSPEC}" "imageleaf/phabricator-mysql:${VERSION}"
    docker tag "imageleaf/phabricator-mysql:${REFSPEC}" "imageleaf/phabricator-mysql:latest"

    docker push "imageleaf/phabricator-mysql:${REFSPEC}"
    docker push "imageleaf/phabricator-mysql:${VERSION}"
    docker push "imageleaf/phabricator-mysql:latest"
fi
