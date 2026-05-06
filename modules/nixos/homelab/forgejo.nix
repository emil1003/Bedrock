{
  flake.nixosModules."forgejo" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.forgejo = {
        domain = mkOption {
          description = "Domain to publish Forgejo under";
          type = types.str;
          default = "git.${homelab.baseDomain}";
        };

        proxy = mkEnableOption "proxy access through Caddy";
      };

      config =
        let
          cfg = config.homelab.forgejo;
        in
        {
          services = {
            caddy.virtualHosts.${cfg.domain} = mkIf cfg.proxy {
              useACMEHost = homelab.domain;
              extraConfig =
                let
                  port = config.services.forgejo.settings.server.HTTP_PORT;
                in
                ''
                  reverse_proxy http://localhost:${toString port}
                '';
            };

            forgejo = {
              enable = true;

              user = homelab.user;
              group = homelab.group;
            };
          };
        };
    };
}
