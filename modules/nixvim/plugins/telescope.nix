{
  flake.nixvimModules."telescope" =
    { config, ... }:
    {
      plugins.telescope = {
        enable = true;

        settings = {
          defaults = {
            layout_config = {
              horizontal = {
                prompt_position = "top";
              };
            };

            prompt_prefix = "   ";
            sorting_strategy = "ascending";

            mappings."n" = {
              "q".__raw = ''require("telescope.actions").close'';
            };
          };
        };
      };

      keymaps = with config.utils.keymap; [
        # Telescope mappings
        (mkMap "n" "<leader>ff" "<cmd>Telescope find_files<cr>" { desc = "Telescope find files"; })
        (mkMap "n" "<leader>fb" "<cmd>Telescope buffers<cr>" { desc = "Telescope buffers"; })
      ];
    };
}
