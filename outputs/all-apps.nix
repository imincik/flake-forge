{ inputs, lib, ... }:

let
  recipeFiles = (inputs.import-tree.withLib lib).leafs ./apps;

  # This will be called from perSystem, passing { config, lib, pkgs, ... }
  callRecipes = args: map (file: import file args) recipeFiles;
in
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }@args:

    let
      recipes = callRecipes args;
      allOutputs = lib.flatten (map (r: r.forge.apps or [ ]) recipes);
    in
    {
      forge.apps = allOutputs;
    };
}
