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
      # pin zephyr-nix to old version
      # reason: zephyr-sdk, zephyr should match. zmk currently use zephyr 3.5.0+zmkfixes, which is not compatible with zephyr sdk >= 0.17.1
      # so we pin zephyr-nix to this commit to avoid upgrading zephyr sdk to 0.17.2
      url = "github:nix-community/zephyr-nix/5ba6564b7f2db1508bcf87f0f869b8e4f8be96c1";
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
          rec {
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
            packages = pkgs.callPackage ./. { };
            devShells = {
              zmk-sofle = pkgs.mkShell {
                inputsFrom = [ packages.zmk-sofle.passthru.eyelash_sofle_left ];
                nativeBuildInputs = with pkgs; [
                  west2nix
                  python3.pkgs.keymap-drawer
                ];
              };
              zmk-sofle-dongle = pkgs.mkShell {
                inputsFrom = [ packages.zmk-sofle-dongle.passthru.eyelash_sofle_peripheral_left ];
                nativeBuildInputs = with pkgs; [
                  west2nix
                  python3.pkgs.keymap-drawer
                ];
              };
            };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
