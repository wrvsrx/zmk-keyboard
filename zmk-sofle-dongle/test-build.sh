#!/usr/bin/env bash

Zephyr_DIR=$PWD/zephyr/share/zephyr-package/cmake west build -s $PWD/zmk/app -b "nice_nano_v2" -S studio-rpc-usb-uart -- -DZMK_CONFIG=$PWD/config "-DSHIELD=eyelash_sofle_central_dongle;dongle_display" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n -DZMK_EXTRA_MODULES=$PWD/../externals/zmk-sofle-dongle
keymap -c ../externals/zmk-sofle-dongle/keymap_drawer.config.yaml parse -z config/eyelash_sofle.keymap > eyelash_sofle.yaml
XDG_CACHE_HOME=$PWD/keymap-drawer/cache keymap -c ../externals/zmk-sofle-dongle/keymap_drawer.config.yaml draw -j config/eyelash_sofle.json eyelash_sofle.yaml > eyelash_sofle.svg
