{
  buildSofle,
  buildKeymap,
  symlinkJoin,
  runCommand,
}:
let
  keyboardName = "eyelash_offsetkey";
  zmk-offsetkey-dongle-config = runCommand "zmk-sofle-dongle-config" { } ''
    mkdir -p $out
    cp -r ${../externals/zmk-offsetkey-dongle/config/offsetkey.conf} $out/offsetkey.conf
    cp -r ${../externals/zmk-offsetkey-dongle/config/offsetkey.json} $out/offsetkey.json
    cp -r ${../externals/zmk-offsetkey-dongle/config/west.yml} $out/west.yml
    cp -r ${./config/offsetkey.keymap} $out/offsetkey.keymap
  '';
  buildSofle' =
    x:
    buildSofle (
      x
      // {
        west2nixConfig = ./west2nix.toml;
        extraModules = [ ../externals/zmk-offsetkey-dongle ];
        zmkConfig = zmk-offsetkey-dongle-config;
      }
    );
  eyelash_offsetkey_reset = buildSofle' {
    name = "${keyboardName}_reset";
    board = "eyelash_nano";
    shields = [ "settings_reset" ];
  };
  eyelash_offsetkey_central_dongle_oled = buildSofle' {
    name = "${keyboardName}_central_oled";
    board = "eyelash_nano";
    shields = [
      "offsetkey_central_dongle"
      "dongle_display"
    ];
    snippets = [ "studio-rpc-usb-uart" ];
    extraCMakeFlags = [
      "-DCONFIG_ZMK_STUDIO=y"
      "-DCONFIG_ZMK_STUDIO_LOCKING=n"
    ];
  };
  eyelash_offsetkey_peripheral_left = buildSofle' {
    name = "${keyboardName}_peripheral_left";
    board = "eyelash_nano";
    shields = [
      "offsetkey_peripheral_left"
    ];
  };
  eyelash_offsetkey_peripheral_right = buildSofle' {
    name = "${keyboardName}_peripheral_right";
    board = "eyelash_nano";
    shields = [
      "offsetkey_peripheral_right"
    ];
  };
  eyelash_offsetkey_keymap = buildKeymap {
    keymapName = "offsetkey";
    keymapConfig = ../externals/zmk-offsetkey-dongle/keymap_drawer.config.yaml;
    zmkConfig = zmk-offsetkey-dongle-config;
  };
in
symlinkJoin {
  name = "${keyboardName}_firmware";
  paths = [
    eyelash_offsetkey_reset
    eyelash_offsetkey_peripheral_left
    eyelash_offsetkey_central_dongle_oled
    eyelash_offsetkey_peripheral_right
    eyelash_offsetkey_keymap
  ];
  passthru = {
    eyelash_offsetkey_reset = eyelash_offsetkey_reset;
    eyelash_offsetkey_central_dongle_oled = eyelash_offsetkey_central_dongle_oled;
    eyelash_offsetkey_peripheral_left = eyelash_offsetkey_peripheral_left;
    eyelash_offsetkey_peripheral_right = eyelash_offsetkey_peripheral_right;
    eyelash_offsetkey_keymap = eyelash_offsetkey_keymap;
  };
}
