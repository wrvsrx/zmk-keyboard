{
  description = "My zmk keyboard configurations";

  inputs = {
    nur-wrvsrx.url = "github:wrvsrx/nur-packages";
    nixpkgs.follows = "nur-wrvsrx/nixpkgs";
    flake-parts.follows = "nur-wrvsrx/flake-parts";
    west2nix = {
      url = "github:wrvsrx/west2nix/patched-master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr-nix.follows = "zephyr-nix";
    };
    # evaluation warning: zephyr-pythonEnv: Found invalid Python constraints for: ["ruff","spsdk"]
    # Reason: some dependencies of zephyr use too strict version on ruff and spsdk (they use ==)
    zephyr-nix = {
      url = "github:nix-community/zephyr-nix/b614ffaa1343beacaca254213451186af10e88f6";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
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
            packages =
              let
                packages' = pkgs.callPackage ./. { };
              in
              {
                inherit (packages')
                  zmk-sofle
                  zmk-sofle-dongle
                  zmk-offsetkey-dongle
                  ;
              };
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
            formatter = pkgs.nixfmt;
          };
      }
    );
}
