{ pkgs ? import <nixpkgs> {} }:

let

  mongodb =
    (import <nixpkgs> {
      config.permittedInsecurePackages = [
      ];
      config.allowUnfreePredicate =
        pkg: builtins.elem (pkgs.lib.getName pkg) [
          "mongodb-ce"
        ];
    }).mongodb-ce;

  myTestEnv =
    pkgs.writeText
      "my.test.env"
      ''
        CUSTOMCONNSTR_mongo=mongodb://localhost:27017/testdb
        API_SECRET=1234567890abc
        HOSTNAME=localhost
        INSECURE_USE_HTTP=true
        PORT=1337
        NODE_ENV=development
      '';

  exitSh =
    pkgs.writeScript
      "exit.sh"
      ''
        echo -e "-- Stopping MongoDB ------------------------------------"
        killall mongod
      '';

in

  pkgs.mkShell {

    buildInputs = [
      mongodb
      pkgs.nodejs_20
    ];

    shellHook = ''

      trap "${exitSh}" EXIT

      echo -e "-- Environment info ------------------------------------"

      echo -e "* Node.js version: $(node --version)"
      echo -e "* MongoDB version: $(mongod --version | head -n1)"

      echo -e "\n-- Starting MongoDB ------------------------------------"
      mkdir -p mongo-data/
      mongod --dbpath mongo-data/ --fork --logpath mongo-data/mongodb.log

      echo -e "\n-- Creating my.test.env --------------------------------"
      cat ${myTestEnv} > my.test.env
      cat my.test.env

      echo -e "\n-- Ready, set, develop! --------------------------------"

      echo -e "* Set up the Node.js environment via 'npm install'"
      echo -e "* Run all tests via 'npm run-script test'"
      echo -e "* Run individual tests via 'TEST=ar2 npm run-script test-single'"

    '';

  }
