docker-npm-registry-couchapp
============================

NPM registry couchapp container, using couchdb `1.6.0`, node `0.10.29` and npm-registry-couchapp `2.4.3`.

Requires [alexindigo/couchdb](https://registry.hub.docker.com/u/alexindigo/couchdb/) as linked container.

## Run

### Empty registry

```
$ ./run.sh
```

### Full copy

```
$ ./run.sh bash
root@84a7fef8c4c0:/opt/npmjs# ./couchdb_init.sh
```

Run replication as described here: [https://github.com/npm/npm-registry-couchapp](https://github.com/npm/npm-registry-couchapp)
