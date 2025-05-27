{ stdenvNoCC, python3 }:
{
  keymapName,
  keymapConfig,
  zmkConfig,
}:
stdenvNoCC.mkDerivation {
  name = keymapName + "_keymap";
  unpackPhase = "true";
  nativeBuildInputs = [ python3.pkgs.keymap-drawer ];
  buildPhase = ''
    keymap -c ${keymapConfig} parse -z ${zmkConfig}/${keymapName}.keymap > ${keymapName}.yaml
    XDG_CACHE_HOME=${../keymap-drawer/cache} keymap -c ${keymapConfig} draw -j ${zmkConfig}/${keymapName}.json ${keymapName}.yaml > ${keymapName}.svg
  '';
  installPhase = ''
    mkdir -p $out
    cp ${keymapName}.svg $out
  '';
}
