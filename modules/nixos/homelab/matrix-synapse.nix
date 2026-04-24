{
  flake.nixosModules."matrix-synapse" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.matrix-synapse = {
        domain = mkOption {
          description = "Domain to publish Matrix under";
          type = types.str;
          default = "matrix.${homelab.baseDomain}";
        };
      };

      config =
        let
          cfg = config.homelab.matrix-synapse;
        in
        {
          services = {
            caddy.virtualHosts = {
              # Apply delegation onto base domain
              "${homelab.baseDomain}" =
                let
                  clientConfig = {
                    "m.homeserver".base_url = "https://${cfg.domain}";
                    "m.identity_server" = { };
                  };
                  serverConfig = {
                    "m.server" = "${cfg.domain}:443";
                  };
                in
                {
                  useACMEHost = homelab.baseDomain;
                  extraConfig = ''
                    header /.well-known/matrix/* Content-Type application/json
                    header /.well-known/matrix/* Access-Control-Allow-Origin *
                    respond /.well-known/matrix/client `${builtins.toJSON clientConfig}`
                    respond /.well-known/matrix/server `${builtins.toJSON serverConfig}`
                  '';
                };
              "${cfg.domain}" = {
                useACMEHost = homelab.baseDomain;
                extraConfig = ''
                  reverse_proxy /_matrix/* localhost:8008
                '';
              };
            };

            matrix-synapse = {
              enable = true;
              settings = {
                server_name = homelab.baseDomain;
                public_baseurl = "https://${cfg.domain}";

                database = {
                  name = "psycopg2";
                  allow_unsafe_locale = true;
                  args = {
                    user = "matrix-synapse";
                    database = "matrix-synapse";
                    host = "/run/postgresql";
                  };
                };

                registration_shared_secret_path = "/var/lib/matrix-synapse/registration_secret";
              };
            };

            # Database assertions
            postgresql = {
              ensureDatabases = [ "matrix-synapse" ];
              ensureUsers = [
                {
                  name = "matrix-synapse";
                  ensureDBOwnership = true;
                }
              ];
            };
          };
        };
    };
}
