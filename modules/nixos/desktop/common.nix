{
  flake.nixosModules."desktop-common" =
    { pkgs, ... }:
    {
      # Graphical boot
      boot = {
        kernelParams = [ "quiet" ];
        plymouth.enable = true;
      };

      # Basic selection of system services
      services = {
        flatpak.enable = true;
        fwupd.enable = true;
        printing.enable = true;
      };
    };
}
