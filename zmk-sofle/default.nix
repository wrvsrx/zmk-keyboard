{
  buildSofle,
  buildKeymap,
  symlinkJoin,
  runCommand,
}:
let
  keyboardName = "eyelash_sofle";
  zmk-sofle-config = runCommand "zmk-sofle-config" { } ''
    mkdir -p $out
    cp -r ${../externals/zmk-sofle/config/eyelash_sofle.conf} $out/eyelash_sofle.conf
    cp -r ${../externals/zmk-sofle/config/eyelash_sofle.json} $out/eyelash_sofle.json
    cp -r ${../externals/zmk-sofle/config/west.yml} $out/west.yml
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
    name = "${keyboardName}_reset";
    board = "${keyboardName}_left";
    shields = [ "settings_reset" ];
  };
  eyelash_sofle_studio_left = buildSofle' {
    name = "${keyboardName}_studio_left";
    board = "${keyboardName}_left";
    shields = [ "nice_view" ];
    snippets = [ "studio-rpc-usb-uart" ];
    extraCMakeFlags = [
      "-DCONFIG_ZMK_STUDIO=y"
      "-DCONFIG_ZMK_STUDIO_LOCKING=n"
    ];
  };
  eyelash_sofle_left = buildSofle' {
    board = "${keyboardName}_left";
    shields = [ "nice_view" ];
  };
  eyelash_sofle_right = buildSofle' {
    board = "${keyboardName}_right";
    shields = [ "nice_view" ];
  };
  eyelash_sofle_keymap = buildKeymap {
    keymapName = keyboardName;
    keymapConfig = ../externals/zmk-sofle/keymap_drawer.config.yaml;
    zmkConfig = zmk-sofle-config;
  };
in
symlinkJoin {
  name = "${keyboardName}_firmware";
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
