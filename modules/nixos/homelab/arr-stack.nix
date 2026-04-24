{
  flake.nixosModules."arr-stack" =
    { config, lib, ... }:
    with lib;
    {
      options.homelab.arr-stack = {
        services = mkOption {
          description = "List of services to expose as part of the arr-stack";
          type = with types; listOf str;
          default = [
            "radarr"
            "sonarr"
            "lidarr"
            "prowlarr"
          ];
        };

        expose = mkEnableOption "exposing service ports directly";

        proxy = mkEnableOption "proxying through caddy";
      };

      config =
        let
          inherit (config) homelab;
          cfg = config.homelab.arr-stack;

          buildService = service: {
            ${service} = mkMerge [
              {
                enable = true;
                openFirewall = cfg.expose;
              }
              (
                if service != "prowlarr" then
                  {
                    user = homelab.user;
                    group = homelab.group;
                  }
                else
                  { }
              )
            ];
          };

          buildVirtualHost =
            service:
            let
              domain = "${service}.${homelab.baseDomain}";
              port = config.services.${service}.settings.server.port;
            in
            {
              ${domain} = {
                extraConfig = ''
                  reverse_proxy http://localhost:${toString port}
                '';
              };
            };
        in
        {
          services = (mergeAttrsList (map buildService cfg.services)) // {
            caddy.virtualHosts = mkIf cfg.proxy (mergeAttrsList (map buildVirtualHost cfg.services));
          };
        };
    };
}
