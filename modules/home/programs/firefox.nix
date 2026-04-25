{
  flake.homeModules."firefox" =
    { config, pkgs, ... }:
    {
      programs.firefox = {
        enable = true;

        # Force new config path
        configPath = "${config.xdg.configHome}/mozilla/firefox";

        profiles."Personal" = {
          id = 0;

          containers = {
            "Incognito" = {
              color = "purple";
              icon = "fingerprint";
              id = 1;
            };
          };

          search = {
            default = "ddg";
            force = true;
            engines = {
              "nix-packages" = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nix" ];
              };

              "nixos-options" = {
                name = "NixOS Options";
                urls = [
                  {
                    template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nixos" ];
              };
            };
          };
        };
      };

      home.packages = [ pkgs.firefox-gnome-theme ];
    };
}
