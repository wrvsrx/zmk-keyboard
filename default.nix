{
  stdenv,
  stdenvNoCC,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  mkWest2nixHook,
  gitMinimal,
  lib,
  symlinkJoin,
  qemu,
  runCommand,
  python3,
  bash,
  which,
}:

let
  west2nixHook = mkWest2nixHook {
    manifest = ./west2nix.toml;
  };
  west2nixModules = stdenv.mkDerivation {
    name = "west2nix-modules";
    unpackPhase = "true";
    nativeBuildInputs = [
      west2nixHook
      gitMinimal
    ];
    env = {
      dontUseWestConfigure = true;
      dontUseWestBuild = true;
      dontFixup = true;
    };
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';
  };
  buildSofle =
    {
      name ? board,
      board,
      shields,
      snippets ? [ ],
      extraCMakeFlags ? [ ],
    }:
    stdenv.mkDerivation {
      inherit name;
      src = west2nixModules;
      env = {
        Zephyr_DIR = "zephyr/share/zephyr-package/cmake";
        dontUseCmakeConfigure = true;
      };
      nativeBuildInputs = [
        (zephyr.pythonEnv.override {
          # use python3 after nur overlay
          inherit python3;
          zephyr-src =
            (lib.lists.findFirst (x: x.name == "zephyr") null west2nixHook.projectsWithFakeGit).src;
        })
        zephyr.hosttools-nix
        gitMinimal
        cmake
        ninja
        which
      ];
      buildInputs = [
        (zephyr.sdk.override {
          targets = [
            "arm-zephyr-eabi"
          ];
        })
      ];
      buildPhase =
        let
          westBuildFlags =
            [
              "-s"
              "zmk/app"
              "-b"
              board
            ]
            ++ (builtins.concatMap (snippet: [
              "-S"
              snippet
            ]) snippets)
            ++ [
              "--"
              ("-DZMK_CONFIG=${./.}" + "/config")
              "-DZMK_EXTRA_MODULES=${./externals/zmk-sofle}"
              "-DSHIELD=${lib.concatStringsSep ";" shields}"
            ]
            ++ extraCMakeFlags;
        in
        ''
          mkdir config
          cp ${./config/west.yml} config/west.yml
          west init -l config

          sed -i "s|#!/usr/bin/env python3|#!$(which python)|g" \
            modules/lib/nanopb/generator/protoc \
            modules/lib/nanopb/generator/protoc-gen-nanopb

          west build ${builtins.concatStringsSep " " westBuildFlags}
        '';
      installPhase = ''
        mkdir $out
        cp build/zephyr/zmk.uf2 $out/$name.uf2
      '';
    };
in
{
  packages = rec {
    eyelash_sofle_reset = buildSofle {
      name = "eyelash_sofle_reset";
      board = "eyelash_sofle_left";
      shields = [ "settings_reset" ];
    };
    eyelash_sofle_studio_left = buildSofle {
      name = "eyelash_sofle_studio_left";
      board = "eyelash_sofle_left";
      shields = [ "nice_view" ];
      snippets = [ "studio-rpc-usb-uart" ];
      extraCMakeFlags = [
        "-DCONFIG_ZMK_STUDIO=y"
        "-DCONFIG_ZMK_STUDIO_LOCKING=n"
      ];
    };
    eyelash_sofle_left = buildSofle {
      board = "eyelash_sofle_left";
      shields = [ "nice_view" ];
    };
    eyelash_sofle_right = buildSofle {
      board = "eyelash_sofle_right";
      shields = [ "nice_view_custom" ];
    };
    eyelash_sofle_keymap = stdenvNoCC.mkDerivation {
      name = "eyelash_sofle_keymap";
      src = ./.;
      nativeBuildInputs = [ python3.pkgs.keymap-drawer ];
      buildPhase = ''
        keymap -c ${./externals/zmk-sofle/keymap_drawer.config.yaml} parse -z config/eyelash_sofle.keymap > eyelash_sofle.yaml
        XDG_CACHE_HOME=$PWD/keymap-drawer/cache keymap -c ${./externals/zmk-sofle/keymap_drawer.config.yaml} draw -j config/eyelash_sofle.json eyelash_sofle.yaml > eyelash_sofle.svg
      '';
      installPhase = ''
        mkdir -p $out
        cp eyelash_sofle.svg $out
      '';
    };
    default = symlinkJoin {
      name = "eyelash_sofle_firmware";
      paths = [
        eyelash_sofle_reset
        eyelash_sofle_left
        eyelash_sofle_studio_left
        eyelash_sofle_right
        eyelash_sofle_keymap
      ];
    };
  };
}
