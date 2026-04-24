{
  flake.nixvimModules."language-support" =
    { config, pkgs, ... }:
    {
      plugins.lsp = {
        enable = true;

        servers = {
          # Go
          gopls.enable = true;
          # Nix
          nil_ls.enable = true;
          # Rust
          # rust_analyzer.enable = true;
          # LaTeX
          texlab = {
            enable = true;
            settings.texlab = {
              # Automatic PDF compile on save
              build = {
                onSave = true;
                executable = "${pkgs.tectonic}/bin/tectonic";
                args = [
                  "-X"
                  "compile"
                  "%f"
                  "--keep-logs"
                ];
              };
            };
          };
        };

        # Configure diagnostics
        luaConfig.pre = ''
          local x = vim.diagnostic.severity
          vim.diagnostic.config {
            virtual_text = { prefix = "" },
            signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
            underline = true,
            float = { border = "single" },
          }
        '';
      };

      plugins.treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
        ];
      };

      keymaps = with config.utils.keymap; [
        # LSP keymaps
        (mkMap "n" "K" { __raw = "vim.lsp.buf.hover"; } { desc = "LSP hover"; })
        (mkMap "n" "<leader>fm" { __raw = "vim.lsp.buf.format"; } { desc = "LSP format file"; })
      ];
    };
}
