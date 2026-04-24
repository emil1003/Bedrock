{
  flake.nixosModules."nextdns-proxy" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.nextdns-proxy = {
        domain = mkOption {
          description = "Domain to expose nextdns-proxy on";
          type = types.str;
          default = "nextdns-proxy.${homelab.baseDomain}";
        };
      };

      config =
        let
          cfg = config.homelab.nextdns-proxy;
        in
        {
          services.caddy.virtualHosts.${cfg.domain} = {
            useACMEHost = homelab.baseDomain;
            extraConfig = ''
              reverse_proxy https://dns.nextdns.io {
                header_up Host "dns.nextdns.io"
              }
            '';
          };
        };
    };
}
