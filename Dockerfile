# alexindigo/couchdb
FROM  alexindigo/couchdb
MAINTAINER Alex Indigo <iam@alexindigo.com>

# Settings
ENV NODE_URL http://nodejs.org/dist/v0.10.26/node-v0.10.26.tar.gz
ENV NPMJS_VERSION 2.0.5
ENV NPMJS_URL https://github.com/alexindigo/npmjs.org/archive/new-install-docs.tar.gz

# Local config
RUN echo "\
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

# Get Node
RUN mkdir -p /opt/node && \
    curl -s -o /opt/node.tar.gz ${NODE_URL} && \
    tar -C /opt/node --strip-components 1 -xzf /opt/node.tar.gz && \
    rm /opt/node.tar.gz

# Build Node
RUN cd /opt/node && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    rm -rf /opt/node

# Get NPM registry app
RUN mkdir -p /opt/npmjs && \
    curl -s -L -o /opt/npmjs.tar.gz ${NPMJS_URL} && \
    tar -C /opt/npmjs --strip-components 1 -xzf /opt/npmjs.tar.gz && \
    rm /opt/npmjs.tar.gz

# Build NPM registry app
RUN cd /opt/npmjs && \
    npm install

# Make dependencies available as standalone apps
RUN ln -s /opt/npmjs/node_modules/.bin/couchapp /usr/local/bin/couchapp && \
    ln -s /opt/npmjs/node_modules/.bin/json /usr/local/bin/json

# Remove unnecessary dependencies
RUN sed -i'' 's/`git describe --tags`/v'${NPMJS_VERSION}'/' /opt/npmjs/push.sh
RUN sed -i'' -e 's/^ips=.*$/ips=127.0.0.1/' /opt/npmjs/load-views.sh

# Set NPM config
RUN npm config set _npmjs.org:couch=http://localhost:5984/registry

# Load structure + timeless hack
# and prevent overriding packages
RUN /etc/init.d/couchdb start && \
    sleep 5 && \
    curl -s -X PUT http://localhost:5984/registry && \
    curl -s -X PUT http://localhost:5984/registry/error%3A%20forbidden2 -d '{ "_id": "error: forbidden", "forbidden":"must supply latest _rev to update existing package" }' && \
    cd /opt/npmjs && \
    npm start && \
    npm run load && \
    echo "yes" | npm run copy
