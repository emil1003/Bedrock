{
  flake.nixvimModules."nvim-tree" =
    { config, ... }:
    {
      plugins.nvim-tree = {
        enable = true;

        settings = {
          diagnostics = {
            enable = true;
          };

          filters = {
            custom = [
              "^.git$"
            ];
          };

          hijack_cursor = true;

          renderer = {
            highlight_git = true;
            indent_markers.enable = true;
            root_folder_label = false;

            icons.glyphs = {
              git = {
                unstaged = "☐";
                staged = "☑";
              };
            };
          };

          sort = {
            files_first = true;
          };

          update_focused_file = {
            enable = true;
            update_root = false;
          };
        };
      };

      keymaps = with config.utils.keymap; [
        # Nvim-tree keymaps
        (mkMap "n" "<C-n>" "<cmd>NvimTreeToggle<cr>" { desc = "Toggle NvimTree"; })
        (mkMap "n" "<leader>e" "<cmd>NvimTreeFocus<cr>" { desc = "Focus NvimTree"; })
      ];
    };
}
