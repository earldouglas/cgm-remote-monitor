{
  pkgs,
  ...
}:

let

  nodejs = pkgs.nodejs_24;

  api-secret = "1234567890abc";
  api-secret-sha1 = builtins.hashString "sha1" api-secret;

  mongodb-port = builtins.toString 1338;
  mongodb-root = "mongodb://localhost:${mongodb-port}";
  mongodb-name = "nightscout";

  nightscout-port = builtins.toString 1337;

  plugins = builtins.getEnv "ENABLE";

  proxy-port-http = builtins.toString 8080;
  proxy-port-https = builtins.toString 8443;

  cert = pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
    mkdir -p $out
    openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 365 -nodes \
      -keyout $out/cert.key -out $out/cert.crt \
      -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
  '';

in
{

  # https://devenv.sh/services/
  services.mongodb.enable = true;
  services.mongodb.additionalArgs = [
    "--port"
    "${mongodb-port}"
  ];

  # https://devenv.sh/processes/
  processes.nightscout.exec = ''
    export BASE_URL=http://localhost:${nightscout-port}
    export MONGODB_URI=${mongodb-root}/${mongodb-name}
    export API_SECRET=${api-secret}
    export PORT=${nightscout-port}
    export ENABLE="${plugins}"

    echo 'Starting Nightscout...'

    ${nodejs}/bin/npm install
    ./node_modules/.bin/nodemon --inspect lib/server/server.js 0.0.0.0
  '';

  # https://devenv.sh/processes/
  processes.hydrate.exec = ''
    echo 'Waiting for Nightscout...'
    ${pkgs.curl}/bin/curl \
      'https://localhost:${nightscout-port}/api/v1/status' \
      -k \
      -s \
      --retry 30 \
      --retry-delay 1 \
      --retry-connrefused \
      -H 'api-secret: ${api-secret-sha1}' > /dev/null 2> /dev/null

    echo 'Setting default profile...'
    ${pkgs.curl}/bin/curl \
      'https://localhost:${nightscout-port}/api/v1/profile' \
      -k \
      -s \
      -X PUT \
      -H 'Content-Type: application/json' \
      -H 'api-secret: ${api-secret-sha1}' \
      --data @./tests/default-profile.json

    echo 'Hydration complete.'
  '';

  # https://devenv.sh/services/nginx/#servicesnginxenable
  services.nginx.enable = true;
  services.nginx.httpConfig = ''
    server {
      listen ${proxy-port-http};
      server_name localhost;
      return 301 https://$host:${proxy-port-https}$request_uri;
    }

    server {
      listen ${proxy-port-https} ssl;
      server_name localhost;

      ssl_certificate ${cert}/cert.crt;
      ssl_certificate_key ${cert}/cert.key;

      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;

      location / {
        proxy_pass http://localhost:${nightscout-port};

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      }
    }
  '';
}
