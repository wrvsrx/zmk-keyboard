{
  newScope,
  lib,
  symlinkJoin,
  runCommand,
}:
lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
    buildSofle = callPackage ./build-sofle { };
    buildKeymap = callPackage ./build-keymap { };
  in
  {
    zmk-sofle = import ./zmk-sofle {
      inherit
        buildSofle
        buildKeymap
        symlinkJoin
        runCommand
        ;
    };
    zmk-sofle-dongle = import ./zmk-sofle-dongle {
      inherit
        buildSofle
        buildKeymap
        symlinkJoin
        runCommand
        ;
    };
    zmk-offsetkey-dongle = import ./zmk-offsetkey-dongle {
      inherit
        buildSofle
        buildKeymap
        symlinkJoin
        runCommand
        ;
    };
  }
)
