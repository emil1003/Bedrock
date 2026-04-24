# Network isolation using systemd-netns
{
  flake.nixosModules."wireguard-netns" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    {
      options.services.wireguard-netns = {
        namespace = mkOption {
          description = "Namespace name";
          type = types.str;
          default = "wg_client";
        };

        configFile = mkOption {
          description = "Path to a WireGuard configuration file";
          type = types.path;
          example = literalExpression ''
            pkgs.writeText "wg0.conf" '''
              [Interface]
              PrivateKey = <client private key>

              [Peer]
              PublicKey = <server public key>
              Endpoint = <server ip:port>
            '''
          '';
        };

        ip = {
          v4 = mkOption {
            description = "Private IPv4 address";
            type = types.str;
          };
          v6 = mkOption {
            description = "(Optional) Private IPv6 address";
            type = with types; nullOr str;
          };
          dns = mkOption {
            description = "Server DNS IP";
            type = types.str;
          };
        };

        serviceBinds = mkOption {
          description = "List of services that should bind to the network namespace";
          type = with types; listOf str;
          default = [ ];
        };
      };

      config =
        let
          cfg = config.services.wireguard-netns;
        in
        {
          systemd.services = {
            # Namespace host service
            "netns@" = {
              description = "%I network namespace";
              before = [ "network.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
                ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
                PrivateMounts = false;
              };
            };

            # Interface host service
            ${cfg.namespace} = {
              description = "${cfg.namespace} network interface";
              bindsTo = [ "netns@${cfg.namespace}.service" ];
              requires = [ "network-online.target" ];
              after = [ "netns@${cfg.namespace}.service" ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writers.writeBash "wg-up" ''
                  set -e
                  ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
                  ${pkgs.iproute2}/bin/ip link set wg0 netns ${cfg.namespace}
                  ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} address add ${cfg.ip.v4} dev wg0
                  ${optionalString (cfg.ip.v6 != null) ''
                    ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} address add ${cfg.ip.v6} dev wg0
                  ''}
                  ${pkgs.iproute2}/bin/ip netns exec ${cfg.namespace} \
                  ${pkgs.wireguard-tools}/bin/wg setconf wg0 ${cfg.configFile}
                  ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} link set wg0 up
                  ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} link set lo up
                  ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} route add default dev wg0
                '';
                ExecStop = pkgs.writers.writeBash "wg-down" ''
                  set -e
                  ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} route del default dev wg0
                  ${pkgs.iproute2}/bin/ip -n ${cfg.namespace} link del wg0
                '';
              };
            };
          }
          # Bind services
          // genAttrs cfg.serviceBinds (s: {
            bindsTo = [ "netns@${cfg.namespace}.service" ];
            requires = [
              "network-online.target"
              "${cfg.namespace}.service"
            ];
            serviceConfig.NetworkNamespacePath = [ "/var/run/netns/${cfg.namespace}" ];
          });

          # Create a resolv.conf for the namespace
          environment.etc."netns/${cfg.namespace}/resolv.conf".text = "nameserver ${cfg.ip.dns}";
        };
    };
}
