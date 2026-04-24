{
  flake.nixosModules."systemd-network" = _: {
    systemd.network = {
      enable = true;
      config.networkConfig = {
        # Use DHCP-advertised domain as search domain
        UseDomains = true;
      };
    };

    networking.useNetworkd = true;
  };
}
