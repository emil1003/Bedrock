{ inputs, self, ... }:
{
  perSystem =
    { system, ... }:
    {
      nixvimConfigurations."neovim" = inputs.nixvim.lib.evalNixvim {
        inherit system;
        modules = with self.nixvimModules; [
          common
          language-support
          # Plugins
          bufferline
          cmp
          codecompanion
          gitsigns
          lualine
          nvim-tree
          render-markdown
          telescope
          which-key
        ];
      };
    };
}
