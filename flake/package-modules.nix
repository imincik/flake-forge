{ inputs, ... }:

{
  flake.modules = {
    basic = import ./../modules/basic.nix;
  };
}
