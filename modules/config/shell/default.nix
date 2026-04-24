{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells."default" = pkgs.mkShell {
        packages = with pkgs; [
          disko
          nh
        ];
      };
    };
}
