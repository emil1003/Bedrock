{ inputs, ... }:
{
  imports = with inputs; [
    home-manager.flakeModules.default
    nixvim.flakeModules.default
  ];

  nixvim = {
    packages.enable = true;
  };

  systems = [ "x86_64-linux" ];
}
