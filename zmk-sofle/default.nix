{
  buildSofle,
  buildKeymap,
  symlinkJoin,
  runCommand,
}:
let
  zmk-sofle-config = runCommand "zmk-sofle-config" { } ''
    mkdir -p $out
    cp -r ${../externals/zmk-sofle/config/eyelash_sofle.conf} $out/eyelash_sofle.conf
    cp -r ${../externals/zmk-sofle/config/eyelash_sofle.json} $out/eyelash_sofle.json
    cp -r ${./config/west.yml} $out/west.yml
    cp -r ${./config/eyelash_sofle.keymap} $out/eyelash_sofle.keymap
  '';
  buildSofle' =
    x:
    buildSofle (
      x
      // {
        west2nixConfig = ./west2nix.toml;
        extraModules = [ ../externals/zmk-sofle ];
        zmkConfig = zmk-sofle-config;
      }
    );
  eyelash_sofle_reset = buildSofle' {
    name = "eyelash_sofle_reset";
    board = "eyelash_sofle_left";
    shields = [ "settings_reset" ];
  };
  eyelash_sofle_studio_left = buildSofle' {
    name = "eyelash_sofle_studio_left";
    board = "eyelash_sofle_left";
    shields = [ "nice_view" ];
    snippets = [ "studio-rpc-usb-uart" ];
    extraCMakeFlags = [
      "-DCONFIG_ZMK_STUDIO=y"
      "-DCONFIG_ZMK_STUDIO_LOCKING=n"
    ];
  };
  eyelash_sofle_left = buildSofle' {
    board = "eyelash_sofle_left";
    shields = [ "nice_view" ];
  };
  eyelash_sofle_right = buildSofle' {
    board = "eyelash_sofle_right";
    shields = [ "nice_view_custom" ];
  };
  eyelash_sofle_keymap = buildKeymap {
    name = "eyelash_sofle_keymap";
    keymapConfig = ../externals/zmk-sofle/keymap_drawer.config.yaml;
    keymap = ./config/eyelash_sofle.keymap;
    keymapJSON = ../externals/zmk-sofle/config/eyelash_sofle.json;
  };
in
symlinkJoin {
  name = "eyelash_sofle_firmware";
  paths = [
    eyelash_sofle_reset
    eyelash_sofle_left
    eyelash_sofle_studio_left
    eyelash_sofle_right
    eyelash_sofle_keymap
  ];
  passthru = {
    inherit
      eyelash_sofle_reset
      eyelash_sofle_left
      eyelash_sofle_studio_left
      eyelash_sofle_right
      eyelash_sofle_keymap
      ;
  };
}
