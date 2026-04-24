{
  flake.nixosModules."transmission" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.transmission = {
        # Transmission options
        domain = mkOption {
          description = "Domain to expose Transmission under";
          type = types.str;
          default = "transmission.${homelab.baseDomain}";
        };

        storageDir = mkOption {
          description = "Where to store downloads";
          type = types.path;
          default = "/var/lib/${service}";
        };

        settings = mkOption {
          description = "Extra settings for Transmission";
          type = types.attrs;
          default = { };
        };

        # Networking options
        attachToNamespace = mkEnableOption "attaching to wireguard-netns";

        expose = mkEnableOption "open service ports in firewall";

        proxy = mkEnableOption "proxy access through Caddy";
      };

      config =
        let
          cfg = config.homelab.transmission;
          netns = config.services.wireguard-netns;
          port = 9091;
        in
        {
          services = {
            transmission = {
              enable = true;
              package = mkDefault pkgs.transmission_4;
              user = homelab.user;
              group = homelab.group;

              settings = mkMerge [
                {
                  encryption = 2; # Force BT encryption
                  rpc-host-whitelist = cfg.domain;
                  download-dir = "${cfg.storageDir}/Downloads";
                  incomplete-dir = "${cfg.storageDir}/.incomplete";
                }
                (mkIf cfg.attachToNamespace {
                  # Attempt at fix for https://github.com/transmission/transmission/issues/3285
                  bind-address-ipv4 = netns.ip.v4 or "0.0.0.0";
                  bind-address-ipv6 = netns.ip.v6 or "::";
                })
                # External config last, so it overrides
                cfg.settings
              ];
            };

            # Bind service to namespaced network
            wireguard-netns.serviceBinds = mkIf cfg.attachToNamespace [ "transmission" ];
          };

          systemd = mkMerge [
            {
              # Create directories
              tmpfiles.rules = [
                "d ${cfg.storageDir}/Downloads 0775 ${homelab.user} ${homelab.group} - -"
                "d ${cfg.storageDir}/.incomplete 0775 ${homelab.user} ${homelab.group} - -"
              ];
            }
            # Network namespace config
            (mkIf cfg.attachToNamespace {
              # Socket for proxying WebUI (receiver)
              sockets."transmission-proxy" = {
                enable = true;
                description = "Socket for Proxy to Transmission WebUI";
                listenStreams = [ "${toString port}" ];
                wantedBy = [ "sockets.target" ];
              };

              # Proxy service in namespace, forwarding access to WebUI
              services."transmission-proxy" = {
                enable = true;
                description = "Proxy to Transmission Daemon in Network Namespace";
                requires = [
                  "transmission.service"
                  "transmission-proxy.socket"
                ];
                after = [
                  "transmission.service"
                  "transmission-proxy.socket"
                ];
                unitConfig = {
                  JoinsNamespaceOf = "transmission.service";
                };
                serviceConfig = {
                  User = config.services.transmission.user;
                  Group = config.services.transmission.group;
                  ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString port}";
                  PrivateNetwork = "yes";
                };
              };
            })
          ];
        };
    };
}
