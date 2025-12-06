# zmk-keyboard

This is a repository for compiling the firmware of [zmk-sofle](https://github.com/a741725193/zmk-sofle) and [zmk-sofle-dongle](https://github.com/a741725193/zmk-solfe-dongle)

## zmk-sofle

It fetches three parts of code from the [upstream](https://github.com/a741725193/zmk-sofle):

1. `eyelash_sofle.{conf,json}` (firmware compilation configuration files)
2. `boards` + `zephyr/module.yml` (firmware source code)  
3. `keymap_drawer.config.yaml` (used to generate keymap diagrams)

This repository itself provides:

1. `config/eyelash_sofle.keymap`  

   Keymap configuration file, modify it according to your own key layout.

2. `config/west.yml`  

   West environment configuration file. The upstream's `config/west.yml` had some issues (containing itself), so we removed it.

3. `west2nix.yaml`  

   West2nix configuration file.  

   Update method:  

   ```bash
   west init -l config
   west update --group-filter +optional --group-filter +babblesim
   west2nix
   ```

4. `keymap-drawer/cache`  

   Cache files for keymap-drawer.  

   Update method:  

   ```bash
   keymap -c externals/zmk-sofle/keymap_drawer.config.yaml parse -z config/eyelash_sofle.keymap > eyelash_sofle.yaml
   XDG_CACHE_HOME=$PWD/keymap-drawer/cache keymap -c externals/zmk-sofle/keymap_drawer.config.yaml draw -j config/eyelash_sofle.json eyelash_sofle.yaml > eyelash_sofle.svg
   ```

## zmk-sofle-dongle

Similar to zmk-sofle.

## Build

### Build via nix

``` bash
nix build '.?submodules=1'
```

### Build via cli

``` bash
west init -l config
west update
./test_build.sh
```
