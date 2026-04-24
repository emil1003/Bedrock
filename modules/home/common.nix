{
  flake.homeModules."common" =
    { lib, ... }:
    with lib;
    {
      home.stateVersion = mkDefault "25.11";
    };
}
