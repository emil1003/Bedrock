{ inputs, ... }:
{
  imports = with inputs; [
    home-manager.flakeModules.default
    nixvim.flakeModules.default
  ];

  systems = [ "x86_64-linux" ];
}
