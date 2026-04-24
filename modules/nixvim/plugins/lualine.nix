{
  flake.nixvimModules."lualine" = _: {
    plugins.lualine = {
      enable = true;

      settings = {
        options = {
          disabled_filetypes = {
            winbar = [
              "NvimTree"
            ];
          };
        };

        extensions = [
          "nvim-tree"
        ];

        sections = {
          lualine_b = [
            {
              __unkeyed-1 = "branch";
              icon = "";
            }
          ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
            }
            "diff"
          ];

          lualine_x = [ "diagnostics" ];
          lualine_y = [
            {
              __unkeyed-1 = "lsp_status";
              show_name = false;
            }
            {
              __unkeyed-1 = "filetype";
              colored = false;
            }
          ];
        };
      };
    };
  };
}
