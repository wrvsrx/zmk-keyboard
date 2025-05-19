{
  newScope,
  lib,
  symlinkJoin,
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
      inherit buildSofle buildKeymap symlinkJoin;
    };
  }
)
