{
  flake.nixosModules."ollama" =
    { config, lib, ... }:
    with lib;
    let
      inherit (config) homelab;
    in
    {
      options.homelab.ollama = {
        domain = mkOption {
          description = "Domain to publish Ollama under";
          type = types.str;
          default = "ollama.${homelab.baseDomain}";
        };

        expose = mkEnableOption "open service ports in firewall";

        proxy = mkEnableOption "proxy access through Caddy";
      };

      config =
        let
          port = 11434;
          cfg = config.homelab.ollama;
        in
        {
          services = {
            caddy.virtualHosts.${cfg.domain} = mkIf cfg.proxy {
              useACMEHost = homelab.baseDomain;
              extraconfig = ''
                header Host localhost:${toString port}
                reverse_proxy http://localhost:${toString port}
              '';
            };

            ollama = {
              enable = true;
              host = "0.0.0.0";
              openFirewall = cfg.expose;
            };
          };
        };
    };
}
