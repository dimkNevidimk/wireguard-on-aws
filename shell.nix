{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "wireguard-server-on-ec2-env";
  paths = [
    pkgs.terraformer
    pkgs.terraform
  ];
}
