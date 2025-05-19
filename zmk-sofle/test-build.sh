#!/usr/bin/env bash

Zephyr_DIR=zephyr/share/zephyr-package/cmake west build -s $PWD/zmk/app -b "eyelash_sofle_left" -S studio-rpc-usb-uart -- -DZMK_CONFIG=$PWD/config "-DSHIELD=nice_view" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n -DZMK_EXTRA_MODULES=$PWD/../externals/zmk-sofle
