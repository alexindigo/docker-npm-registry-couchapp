#!/bin/bash
REGISTRY="http://${COUCHDB_PORT_5984_TCP_ADDR}:${COUCHDB_PORT_5984_TCP_PORT}/registry"

# override local config
printf "\
[couch_httpd_auth]\n\
public_fields = appdotnet, avatar, avatarMedium, avatarLarge, date, email, fields, freenode, fullname, github, homepage, name, roles, twitter, type, _id, _rev\n\
users_db_public = true\n\
\n\
[httpd]\n\
secure_rewrites = false\n\
\n\
[couchdb]\n\
delayed_commits = false\n\
\n\
" > /usr/local/etc/couchdb/local.ini

# point script to the right couchdb
sed -i'' -e 's/^ips=.*$/ips='${COUCHDB_PORT_5984_TCP_ADDR}'/' /opt/npmjs/load-views.sh

# set npm config
npm config set npm-registry-couchapp:couch=${REGISTRY}

# Load structure + timeless hack
# and prevent overriding packages
curl -s -X PUT ${REGISTRY} && \
curl -s -X PUT ${REGISTRY}/error%3A%20forbidden2 -d '{ "_id": "error: forbidden", "forbidden":"must supply latest _rev to update existing package" }' && \
npm start && \
npm run load && \
echo "yes" | npm run copy || \
echo "Unable to init couchapp"
