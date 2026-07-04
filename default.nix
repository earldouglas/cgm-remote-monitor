{
  pkgs ? import <nixpkgs> { },
  nodejs ? pkgs.nodejs_24,
  ...
}:
pkgs.buildNpmPackage (finalAttrs: {

  name = "cgm-remote-monitor";

  nativeBuildInputs = [ pkgs.webpack-cli ];

  nodejs = nodejs;

  src = ./.;

  npmInstallFlags = [ "--only=production" ];

  npmBuildScript = "bundle";

  npmDepsHash = "sha256-h2dMUFsMj8IM5Qb9R4FoCGgiEi25qzONe/77rr86jaU=";

})
