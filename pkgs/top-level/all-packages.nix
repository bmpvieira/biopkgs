# Install packages with `nix-env -f default.nix -iA package-name`
{ system ? builtins.currentSystem, pkg ? null }:

let
  nixpkgs = import <nixpkgs> { inherit system; };
  source = (nixpkgs.lib.importJSON ../../nixsrc.json);
  pinPkgs = import (nixpkgs.fetchFromGitHub source.origin) {};

  pkgs = pinPkgs // { 
    stdenv = pinPkgs.stdenv.overrideDerivation (attrs: attrs // {
      lib = attrs.lib // {
        maintainers = import ../../lib/maintainers.nix {} ; 
      };
    }); 
  };

  callPackage = pkgs.lib.callPackageWith (pkgs // pkgs.xlibs // self);

  customPkgs = {
    shell = (import ../../shell.nix).env;
    aspera = callPackage ../tools/networking/aspera {};
    bbcp = callPackage ../tools/networking/bbcp {};
    fastqc = callPackage ../applications/science/biology/fastqc {};
    kmc = callPackage ../applications/science/biology/kmc {};
    ncbi-vdb = callPackage ../applications/science/biology/ncbi-vdb {};
    ngs = callPackage ../applications/science/biology/ngs {};
    seqlib = callPackage ../applications/science/biology/seqlib {};
    sra-tools = callPackage ../applications/science/biology/sra-tools {};
    psmc = callPackage ../applications/science/biology/psmc {};
    trimmomatic = callPackage ../applications/science/biology/trimmomatic {};
    tsunami-udp = callPackage ../tools/networking/tsunami-udp {};
    udpcast = callPackage ../tools/networking/udpcast {};
    udr = callPackage ../tools/networking/udr {};
  };

  allPkgs = pkgs // customPkgs;

  utils = {
    source = source;
    dockerTar = callPackage ./dockerTar.nix { pkg=allPkgs."${pkg}"; };
  };

  self = allPkgs // utils;

in self