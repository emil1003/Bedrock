{
  flake.nixosModules."tailscale" =
    { config, lib, ... }:
    with lib;
    let
      cfg = config.services.tailscale;
    in
    {
      options.services.tailscale = {
        tailnetName = mkOption {
          description = "Tailnet name";
          type = types.str;
        };

        asServer = mkEnableOption "server features";
      };

      config.services.tailscale = mkMerge [
        {
          enable = true;
        }
        (mkIf cfg.asServer {
          useRoutingFeatures = "server";
          extraSetFlags = [ "--advertise-exit-node" ];
        })
      ];
    };
}
