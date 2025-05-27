{
  buildSofle,
  buildKeymap,
  symlinkJoin,
  runCommand,
}:
let
  keyboardName = "eyelash_sofle_dongle";
  zmk-sofle-dongle-config = runCommand "zmk-sofle-dongle-config" { } ''
    mkdir -p $out
    cp -r ${../externals/zmk-sofle-dongle/config/eyelash_sofle.conf} $out/eyelash_sofle.conf
    cp -r ${../externals/zmk-sofle-dongle/config/eyelash_sofle.json} $out/eyelash_sofle.json
    cp -r ${../externals/zmk-sofle-dongle/config/west.yml} $out/west.yml
    cp -r ${./config/eyelash_sofle.keymap} $out/eyelash_sofle.keymap
  '';
  buildSofle' =
    x:
    buildSofle (
      x
      // {
        west2nixConfig = ./west2nix.toml;
        extraModules = [ ../externals/zmk-sofle-dongle ];
        zmkConfig = zmk-sofle-dongle-config;
      }
    );
  eyelash_sofle_reset = buildSofle' {
    name = "${keyboardName}_reset";
    board = "nice_nano_v2";
    shields = [ "settings_reset" ];
  };
  eyelash_sofle_central_dongle_oled = buildSofle' {
    name = "${keyboardName}_central_oled";
    board = "nice_nano_v2";
    shields = [
      "eyelash_sofle_central_dongle"
      "dongle_display"
    ];
    snippets = [ "studio-rpc-usb-uart" ];
    extraCMakeFlags = [
      "-DCONFIG_ZMK_STUDIO=y"
      "-DCONFIG_ZMK_STUDIO_LOCKING=n"
    ];
  };
  eyelash_sofle_peripheral_left = buildSofle' {
    name = "${keyboardName}_peripheral_left";
    board = "nice_nano_v2";
    shields = [
      "eyelash_sofle_peripheral_left"
      "nice_view_custom"
    ];
  };
  eyelash_sofle_peripheral_right = buildSofle' {
    name = "${keyboardName}_peripheral_right";
    board = "nice_nano_v2";
    shields = [
      "eyelash_sofle_peripheral_right"
      "nice_view_custom"
    ];
  };
  eyelash_sofle_keymap = buildKeymap {
    keymapName = keyboardName;
    keymapConfig = ../externals/zmk-sofle-dongle/keymap_drawer.config.yaml;
    zmkConfig = zmk-sofle-dongle-config;
  };
in
symlinkJoin {
  name = "${keyboardName}_firmware";
  paths = [
    eyelash_sofle_reset
    eyelash_sofle_peripheral_left
    eyelash_sofle_central_dongle_oled
    eyelash_sofle_peripheral_right
    eyelash_sofle_keymap
  ];
  passthru = {
    inherit
      eyelash_sofle_reset
      eyelash_sofle_keymap
      eyelash_sofle_peripheral_right
      eyelash_sofle_peripheral_left
      eyelash_sofle_central_dongle_oled
      ;
  };
}
