This repository is a fork of [nightscout/cgm-remote-monitor][1], to be
used for downstream development.

## Setup

Create an `upstream` git remote that points to the upstream repository:

```
$ git remote add upstream https://github.com/nightscout/cgm-remote-monitor.git
$ git fetch upstream
```

## Development

Setup prerequisites (MongoDB, Node.js) by running `nix-shell`:

```
$ nix-shell
-- Environment info ------------------------------------
* Node.js version: v20.19.2
* MongoDB version: db version v8.0.4

-- Starting MongoDB ------------------------------------
about to fork child process, waiting until server is ready for connections.
forked process: 2569991
child process started successfully, parent exiting

-- Creating my.test.env --------------------------------
CUSTOMCONNSTR_mongo=mongodb://localhost:27017/testdb
API_SECRET=1234567890abc
HOSTNAME=localhost
INSECURE_USE_HTTP=true
PORT=1337
NODE_ENV=development

-- Ready, set, develop! --------------------------------
* Set up the Node.js environment via 'npm install'
* Run all tests via 'npm run-script test'
* Run individual tests via 'TEST=ar2 npm run-script test-single'
```

From `nix-shell`, create a new development branch, make some changes,
run some tests, etc.

```
[nix-shell]$ git checkout -b my-new-feature upstream/dev
[nix-shell]$ vim lib/foo/bar.js
[nix-shell]$ npm install
[nix-shell]$ npm run-script test
  494 passing (39s)
```

[1]: https://github.com/nightscout/cgm-remote-monitor
