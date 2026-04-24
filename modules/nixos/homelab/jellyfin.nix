{
  flake.nixosModules."jellyfin" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.jellyfin = {
        # Jellyfin options
        image = mkOption {
          description = "Container image to use";
          type = types.str;
          default = "docker.io/jellyfin/jellyfin:latest";
        };

        pullStrategy = mkOption {
          description = "Container image pull strategy";
          type = types.str;
          default = "newer";
        };

        configDir = mkOption {
          description = "Configuration path";
          type = types.path;
          default = "${homelab.mounts.config}/jellyfin/config";
        };

        cacheDir = mkOption {
          description = "Cache path";
          type = types.path;
          default = "${homelab.mounts.config}/jellyfin/cache";
        };

        dataDir = mkOption {
          description = "Data (media) path";
          type = types.path;
          default = "/mnt/media";
        };

        extraOptions = mkOption {
          description = "Extra options for container creation (ex. render device)";
          type = with types; listOf str;
          default = [ ];
        };

        devices = mkOption {
          description = "Devices to pass into container";
          type = with types; listOf str;
          default = [ ];
        };

        # Network configuration
        domain = mkOption {
          description = "Service domain";
          type = types.str;
          default = "jellyfin.${homelab.baseDomain}";
        };

        expose = mkEnableOption "open service ports in firewall";

        proxy = mkEnableOption "proxy access through Caddy";
      };

      config =
        let
          cfg = config.homelab.jellyfin;
          port = 8096;
        in
        {
          networking.firewall.allowedTCPPorts = mkIf cfg.expose [ port ];

          # Create dirs
          systemd.tmpfiles.rules = [
            "d ${cfg.configDir} 0775 ${homelab.user} ${homelab.group} - -"
            "d ${cfg.cacheDir} 0775 ${homelab.user} ${homelab.group} - -"
            "d ${cfg.dataDir} 0775 ${homelab.user} ${homelab.group} - -"
          ];

          # Add reverse proxy rule
          services.caddy.virtualHosts.${cfg.domain} = mkIf cfg.proxy {
            useACMEHost = homelab.baseDomain;
            extraConfig = ''
              reverse_proxy http://localhost:${toString port}
            '';
          };

          # Setup Jellyfin as container
          virtualisation.oci-containers.containers = {
            jellyfin = {
              image = cfg.image;
              pull = cfg.pullStrategy;
              autoStart = true;
              ports = [ "${toString port}:${toString port}" ];
              volumes = [
                "${cfg.configDir}:/config"
                "${cfg.cacheDir}:/cache"
              ];
              extraOptions = [
                "--mount=type=bind,src=${cfg.dataDir},dst=/media,ro=true"
                "--no-healthcheck"
              ]
              ++ cfg.extraOptions;
              devices = cfg.devices;
              environment = {
                PUID = toString config.users.users.${homelab.user}.uid;
                PGID = toString config.users.groups.${homelab.group}.gid;
              };
            };
          };
        };
    };
}
