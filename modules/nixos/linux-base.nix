{
  flake.nixosModules."linux-base" =
    {
      lib,
      self,
      pkgs,
      ...
    }:
    with lib;
    {
      # systemd-boot + systemd-based initrd
      boot = {
        loader = {
          efi = {
            efiSysMountPoint = mkDefault "/efi";
            canTouchEfiVariables = true;
          };

          systemd-boot = {
            enable = true;
            editor = false;
          };

          timeout = mkDefault 0;
        };

        initrd.systemd.enable = true;
      };

      # Latest kernel
      boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

      # Base package selection
      environment.systemPackages = with pkgs; [
        git
        nano
      ];

      security = {
        sudo.enable = true;
        polkit.enable = true;
      };

      services = {
        homed.enable = true;
        userdbd.silenceHighSystemUsers = true;
        resolved.enable = true;

        openssh = {
          enable = mkDefault true;
          settings = {
            PermitRootLogin = "no";
          };
        };
      };

      # TODO: Switch to Zswap when there's support
      # for no backing device
      zramSwap.enable = true;
    };
}
