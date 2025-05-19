{
  stdenv,
  zephyr, # from zephyr-nix
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

{
  name ? board,
  west2nixConfig,
  westYml,
  extraModules ? [ ],
  board,
  shields,
  snippets ? [ ],
  extraCMakeFlags ? [ ],
}:
let
  west2nixHook = mkWest2nixHook { manifest = west2nixConfig; };
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
in
stdenv.mkDerivation {
  inherit name;
  src = west2nixModules;
  env = {
    Zephyr_DIR = "zephyr/share/zephyr-package/cmake";
    dontUseCmakeConfigure = true;
    dontFixup = true;
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
          "-DZMK_EXTRA_MODULES=${lib.concatStringsSep ";" extraModules}"
          "-DSHIELD=${lib.concatStringsSep ";" shields}"
        ]
        ++ extraCMakeFlags;
    in
    ''
      mkdir config
      cp ${westYml} config/west.yml
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
}
