{
  flake.nixosModules."homelab-common" =
    { config, lib, ... }:
    with lib;
    {
      options.homelab = {
        baseDomain = mkOption {
          description = "Base domain name for homelab services";
          type = types.str;
        };

        cert = {
          email = mkOption {
            description = "Email address to use for CA correspondence";
            type = types.str;
          };

          extraConfig = mkOption {
            description = "Extra cert config (e.g. DNS settings)";
            default = { };
          };
        };

        cloudflared = {
          enable = mkEnableOption "cloudflared for outbound-only tunnel access";

          credentialsFile = mkOption {
            description = "Path to credentials file for authenticating with cloudflared";
            type = types.path;
            example = literalExpression ''
              pkgs.writeText "cloudflare-credentials.json" '''
              {"AccountTag":"secret"."TunnelSecret":"secret","TunnelID":"secret"}
              '''
            '';
          };

          tunnelId = mkOption {
            description = "UUID of the main tunnel to expose services onto";
            type = types.str;
            example = "00000000-0000-0000-0000-000000000000";
          };
        };

        mounts = {
          config = mkOption {
            description = "Path for storing service configuration";
            type = types.str;
            default = "/persist/opt/services";
          };
        };

        user = mkOption {
          description = "User to run the homelab services as";
          default = "share";
          type = types.str;
        };

        group = mkOption {
          description = "Group to run the homelab services as";
          default = "share";
          type = types.str;
        };
      };

      config =
        let
          inherit (config) homelab;
        in
        {
          # ACME cert management
          security.acme = {
            acceptTerms = true;
            defaults = {
              email = homelab.cert.email;
              reloadServices = [ "caddy.service" ];
            };

            certs.${homelab.baseDomain} = mkMerge [
              {
                extraDomainNames = [ "*.${homelab.baseDomain}" ];
                group = config.services.caddy.group;
              }
              homelab.cert.extraConfig
            ];
          };

          services = {
            # Base caddy reverse proxy config
            caddy = {
              enable = true;
              openFirewall = true;
              globalConfig = ''
                auto_https off
              '';
              virtualHosts = {
                "http://${homelab.baseDomain}" = {
                  extraConfig = ''
                    redir https://{host}{uri}
                  '';
                };
                "http://*.${homelab.baseDomain}" = {
                  extraConfig = ''
                    redir https://{host}{uri}
                  '';
                };
              };
            };

            cloudflared = mkIf homelab.cloudflared.enable {
              enable = true;
              tunnels.${homelab.cloudflared.tunnelId} = {
                credentialsFile = homelab.cloudflared.credentialsFile;
                default = "http_status:404";

                # Ingress rules forwarding to caddy
                ingress = {
                  ${homelab.baseDomain} = {
                    service = "http://localhost:${toString config.services.caddy.httpPort}";
                    originRequest.originServerName = homelab.baseDomain;
                  };
                  "*.${homelab.baseDomain}" = {
                    service = "http://localhost:${toString config.services.caddy.httpsPort}";
                    originRequest.originServerName = "*.${homelab.baseDomain}";
                  };
                };
              };
            };
          };

          # Homelab user/group
          users = {
            groups.${homelab.group} = {
              gid = 993;
            };
            users.${homelab.user} = {
              uid = 994;
              isSystemUser = true;
              group = homelab.group;
            };
          };

          # Use podman as container backend
          virtualisation = {
            podman = {
              enable = true;
              dockerCompat = true;
              autoPrune.enable = true;
              defaultNetwork.settings.dns_enabled = true;
            };

            oci-containers.backend = "podman";
          };
        };
    };
}
