{ withSystem, ... }:
{
  flake.homeModules."programs-common" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    {
      # Programs with additional config
      # (which don't warrant separate module)
      programs = {
        bash = {
          enable = true;
        };

        btop = {
          enable = true;
          settings = {
            theme_background = false;
            vim_keys = true;
          };
        };

        nh = {
          enable = true;
          # Opinionated config flake path
          flake = mkDefault "${config.home.homeDirectory}/Flake";
        };
      };

      # Config-less programs
      home.packages =
        with pkgs;
        [
          jq
        ]
        # Flake-defined packages
        ++ (withSystem pkgs.stdenv.hostPlatform.system (
          { config, ... }:
          [
            config.packages."with"
          ]
        ));
    };
}
