{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "wireguard-server-env";
  nativeBuildInputs = [
    pkgs.terraform
  ];
}
