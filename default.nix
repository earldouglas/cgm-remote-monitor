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

  npmDepsHash = "sha256-f5lusxenIEGT8HuxjUKuVLR+vgfQRW+wNx0QIfslUto=";

})
