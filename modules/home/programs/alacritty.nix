{
  flake.homeModules."alacritty" =
    { pkgs, ... }:
    {
      programs.alacritty = {
        enable = true;
        settings = {
          colors.primary.background = "#0f0f13";

          font = {
            normal = {
              family = "FiraCode Nerd Font";
              style = "Retina";
            };
            size = 10;
          };

          mouse = {
            hide_when_typing = true;
          };

          window = {
            dynamic_padding = true;
            decorations = "None";
          };
        };

        theme = "smoooooth";
      };

      home.packages = [ pkgs.nerd-fonts.fira-code ];
    };
}
