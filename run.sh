#!/bin/bash
BASEPATH=$(dirname $(perl -MCwd=realpath -e "print realpath '$0'"))

# if extra arguments present run it in interactive mode
# otherwise just run it once
if [ $# -eq 0 ]
then
RUN_MODE=""
else
RUN_MODE="-t -i"
fi

# run container
docker run ${RUN_MODE} --name npm_registry_init --volumes-from=couchdb --link couchdb:couchdb alexindigo/npm-registry-couchapp "$@"
