{
  buildSofle,
  buildKeymap,
  symlinkJoin,
  runCommand,
}:
# - board: nice_nano_v2
#   shield: eyeslash_sofle_central_dongle dongle_display
#   snippet: studio-rpc-usb-uart
#   cmake-args: -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
#   artifact-name: eyeslash_sofle_central_dongle_oled
# - board: nice_nano_v2
#   shield: eyeslash_sofle_peripheral_left nice_view_custom
# - board: nice_nano_v2
#   shield: eyeslash_sofle_peripheral_right nice_view_custom
# - board: nice_nano_v2
#   shield: settings_reset
let
  zmk-sofle-dongle-module = runCommand "zmk-sofle-dongle-modle" { } ''
    mkdir -p $out
    cp -r ${../externals/zmk-sofle-dongle/config/boards} $out/boards
    cp -r ${../externals/zmk-sofle-dongle/zephyr} $out/zephyr
  '';
  zmk-sofle-dongle-config = runCommand "zmk-sofle-dongle-config" { } ''
    mkdir -p $out
    cp -r ${../externals/zmk-sofle-dongle/config/eyeslash_sofle.conf} $out/eyeslash_sofle.conf
    cp -r ${../externals/zmk-sofle-dongle/config/eyeslash_sofle.json} $out/eyeslash_sofle.json
    cp -r ${../externals/zmk-sofle-dongle/config/west.yml} $out/west.yml
    cp -r ${./config/eyeslash_sofle.keymap} $out/eyeslash_sofle.keymap
  '';
  buildSofle' =
    x:
    buildSofle (
      x
      // {
        west2nixConfig = ./west2nix.toml;
        extraModules = [ zmk-sofle-dongle-module ];
        zmkConfig = zmk-sofle-dongle-config;
      }
    );
  eyelash_sofle_reset = buildSofle' {
    name = "eyelash_sofle_reset";
    board = "nice_nano_v2";
    shields = [ "settings_reset" ];
  };
  eyelash_sofle_central_dongle_oled = buildSofle' {
    name = "eyeslash_sofle_central_dongle_oled";
    board = "nice_nano_v2";
    shields = [
      "eyeslash_sofle_central_dongle"
      "dongle_display"
    ];
    snippets = [ "studio-rpc-usb-uart" ];
    extraCMakeFlags = [
      "-DCONFIG_ZMK_STUDIO=y"
      "-DCONFIG_ZMK_STUDIO_LOCKING=n"
    ];
  };
  eyelash_sofle_peripheral_left = buildSofle' {
    name = "eyeslash_sofle_peripheral_left";
    board = "nice_nano_v2";
    shields = [
      "eyeslash_sofle_peripheral_left"
      "nice_view_custom"
    ];
  };
  eyelash_sofle_peripheral_right = buildSofle' {
    name = "eyeslash_sofle_peripheral_right";
    board = "nice_nano_v2";
    shields = [
      "eyeslash_sofle_peripheral_right"
      "nice_view_custom"
    ];
  };
  eyelash_sofle_keymap = buildKeymap {
    name = "eyelash_sofle_keymap";
    keymapConfig = ../externals/zmk-sofle-dongle/keymap_drawer.config.yaml;
    keymap = ./config/eyeslash_sofle.keymap;
    keymapJSON = ../externals/zmk-sofle-dongle/config/eyeslash_sofle.json;
  };
in
symlinkJoin {
  name = "eyelash_sofle_dongle_firmware";
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
