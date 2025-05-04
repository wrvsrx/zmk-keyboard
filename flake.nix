{
  description = "zmk keyboard";

  inputs = {
    nixpkgs.url = "github:wrvsrx/nixpkgs/patched-nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nur-wrvsrx = {
      url = "github:wrvsrx/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-utils.follows = "flake-utils";
    };
    west2nix = {
      url = "github:wrvsrx/west2nix/patched-master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr-nix.follows = "zephyr-nix";
    };
    zephyr-nix = {
      url = "github:adisbladis/zephyr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, ... }:
      {
        systems = [ "x86_64-linux" ];
        perSystem =
          { pkgs, system, ... }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.nur-wrvsrx.overlays.default
                (final: prev: {
                  inherit (inputs.west2nix.lib.mkWest2nix { pkgs = prev; })
                    mkWest2nixHook
                    ;
                  zephyr = inputs.zephyr-nix.packages.${system};
                  west2nix = inputs.west2nix.packages.${system}.default;
                })
              ];
            };
            devShells.default =
              with pkgs;
              let
                west2nixHook = mkWest2nixHook {
                  manifest = ./west2nix.toml;
                };
              in
              mkShell {
                nativeBuildInputs = [
                  west2nix
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
              };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
