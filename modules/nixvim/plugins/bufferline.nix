{
  flake.nixvimModules."bufferline" = _: {
    plugins.bufferline = {
      enable = true;

      settings = {
        options = {
          indicator = {
            style = "none";
          };

          offsets = [
            {
              filetype = "NvimTree";
              highlight = "Directory";
              separator = true;
            }
          ];

          style_preset.__raw = ''require("bufferline").style_preset.no_italic'';
        };
      };
    };
  };
}
