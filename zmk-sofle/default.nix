{
  buildSofle,
  buildKeymap,
  symlinkJoin,
}:
let
  buildSofle' =
    x:
    buildSofle (
      x
      // {
        west2nixConfig = ./west2nix.toml;
        westYml = ./config/west.yml;
        extraModules = [ ../externals/zmk-sofle ];
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
