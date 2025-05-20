#!/usr/bin/env bash

cp -r $PWD/../externals/zmk-sofle-dongle/config/boards/ $PWD/../externals/zmk-sofle-dongle/boards/
Zephyr_DIR=zephyr/share/zephyr-package/cmake west build -s $PWD/zmk/app -b "nice_nano_v2" -S studio-rpc-usb-uart -- -DZMK_CONFIG=$PWD/config "-DSHIELD=eyeslash_sofle_central_dongle;dongle_display" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n -DZMK_EXTRA_MODULES=$PWD/../externals/zmk-sofle-dongle
rm -r $PWD/../externals/zmk-sofle-dongle/boards/
