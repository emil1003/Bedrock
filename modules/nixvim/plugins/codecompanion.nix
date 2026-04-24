{
  flake.nixvimModules."codecompanion" =
    { config, ... }:
    {
      plugins.codecompanion = {
        enable = true;
      };

      keymaps = with config.utils.keymap; [
        (mkMap "n" "<leader>a" "<cmd>CodeCompanionChat toggle<cr>" { desc = "Toggle CodeCompanion Chat"; })
      ];
    };
}
