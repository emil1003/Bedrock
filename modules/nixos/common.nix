{
  flake.nixosModules."common" =
    { lib, ... }:
    with lib;
    {
      nix = {
        optimise = {
          automatic = mkDefault true;
          dates = [ "weekly" ];
        };

        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = mkDefault "25.11";
    };
}
