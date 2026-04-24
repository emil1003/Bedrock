{
  flake.nixosModules."uptime-kuma" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.uptime-kuma = {
        domain = mkOption {
          description = "Domain to publish Uptime-kuma under";
          type = types.str;
          default = "uptime.${homelab.baseDomain}";
        };

        statusAlias = mkEnableOption "forwarding status.<baseDomain> to Uptime-kuma";

        expose = mkEnableOption "local direct access to web UI";

        proxy = mkEnableOption "proxy access through Caddy";
      };

      config =
        let
          cfg = config.homelab.uptime-kuma;
          port = 3001;
        in
        {
          networking.firewall.allowedTCPPorts = mkIf cfg.expose [ port ];

          services = {
            caddy.virtualHosts.${cfg.domain} = mkIf cfg.proxy {
              useACMEHost = homelab.baseDomain;
              serverAliases = mkIf cfg.statusAlias [ "status.${config.homelab.baseDomain}" ];
              extraConfig = ''
                reverse_proxy http://localhost:${toString port}
              '';
            };

            uptime-kuma.enable = true;
          };
        };
    };
}
