{
  flake.nixosModules."desktop-gnome" =
    { pkgs, ... }:
    {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      environment.systemPackages = with pkgs; [
        gnome-tweaks
        morewaita-icon-theme

        # Default set of extensions
        gnomeExtensions.dash-to-dock
        gnomeExtensions.vitals
      ];
    };
}
