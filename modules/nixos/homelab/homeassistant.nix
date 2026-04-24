{
  flake.nixosModules."homeassistant" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.homeassistant = {
        # Home Assistant options
        image = mkOption {
          description = "Container image URL to use";
          type = types.str;
          default = "docker.io/homeassistant/home-assistant:stable";
        };

        pullStrategy = mkOption {
          description = "Container image pull strategy";
          type = types.str;
          default = "newer";
        };

        configDir = mkOption {
          description = "Path to configuration";
          type = types.path;
          default = "${homelab.mounts.config}/homeassistant";
        };

        extraOptions = mkOption {
          description = "Extra options for container creation (eg. exposing devices)";
          type = types.listOf types.str;
          default = [ ];
        };

        # Network exposing options
        domain = mkOption {
          description = "Subdomain of homelab domain to expose service on";
          type = types.str;
          default = "home.${homelab.baseDomain}";
        };

        expose = mkEnableOption "local direct access to web UI";

        proxy = mkEnableOption "proxy access through Caddy";
      };

      config =
        let
          port = 8123;
          cfg = config.homelab.homeassistant;
        in
        {
          networking.firewall = {
            # Expose WebUI
            allowedTCPPorts = mkIf cfg.expose [ port ];
            # HomeKit, up to 7 instances
            allowedTCPPortRanges = [
              {
                from = 21063;
                to = 21070;
              }
            ];
            # Zeroconf
            allowedUDPPorts = [ 5353 ];
          };

          # Ensure config dir exists and is owned by homelab user
          systemd.tmpfiles.rules = [ "d ${cfg.configDir} 0775 ${homelab.user} ${homelab.group} - -" ];

          services = {
            # Caddy host config
            caddy.virtualHosts."${cfg.domain}" = mkIf cfg.proxy {
              useACMEHost = homelab.baseDomain;
              extraConfig = ''
                reverse_proxy http://localhost:${toString port}
              '';
            };
          };

          # Setup Home Assistant as container
          virtualisation.oci-containers.containers = {
            homeassistant = {
              image = cfg.image;
              pull = cfg.pullStrategy;
              autoStart = true;
              privileged = true;
              # Host networking
              extraOptions = [ "--network=host" ] ++ cfg.extraOptions;
              volumes = [ "${cfg.configDir}:/config" ];
              environment = {
                TZ = config.time.timeZone;
                PUID = toString config.users.users.${homelab.user}.uid;
                PGID = toString config.users.groups.${homelab.group}.gid;
              };
            };
          };
        };
    };
}
