{ stdenvNoCC, python3 }:
{
  name,
  keymapConfig,
  keymap,
  keymapJSON,
}:
stdenvNoCC.mkDerivation {
  inherit name;
  unpackPhase = "true";
  nativeBuildInputs = [ python3.pkgs.keymap-drawer ];
  buildPhase = ''
    keymap -c ${keymapConfig} parse -z ${keymap} > eyelash_sofle.yaml
    XDG_CACHE_HOME=${../keymap-drawer/cache} keymap -c ${keymapConfig} draw -j ${keymapJSON} eyelash_sofle.yaml > eyelash_sofle.svg
  '';
  installPhase = ''
    mkdir -p $out
    cp eyelash_sofle.svg $out
  '';
}
