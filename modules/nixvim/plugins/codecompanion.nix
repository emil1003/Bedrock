{
  flake.nixvimModules."codecompanion" =
    { config, pkgs, ... }:
    {
      plugins = {
        codecompanion = {
          enable = true;
        };

        # YAML treesitter needed for frontmatter
        treesitter = {
          enable = true;

          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            yaml
          ];
        };

        # render-markdown.nvim support
        render-markdown.settings = {
          file_types = [
            "markdown"
            "codecompanion"
          ];
        };
      };

      keymaps = with config.utils.keymap; [
        (mkMap "n" "<leader>a" "<cmd>CodeCompanionChat toggle<cr>" { desc = "Toggle CodeCompanion Chat"; })
      ];
    };
}
