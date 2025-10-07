{ inputs, lib, ... }:

let
  recipeFiles = (inputs.import-tree.withLib lib).leafs ./packages;

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
      recipes = callRecipes (args // {
        # Add mypkgs as extra recipe argument
        mypkgs = config.packages;
      });
      allOutputs = lib.flatten (map (r: r.forge.packages or [ ]) recipes);
    in
    {
      forge.packages = allOutputs;
    };
}
