{
  flake.nixvimModules."common" =
    { config, lib, ... }:
    with lib;
    {
      options = {
        utils = mkOption {
          type = types.attrs;
          default = { };
        };
      };

      config = {
        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        opts = {
          laststatus = 3;
          showmode = false;
          splitkeep = "screen";
          cursorline = true;
          cursorlineopt = "number";
          clipboard = "unnamedplus";

          # Indenting
          expandtab = true;
          shiftwidth = 2;
          smartindent = true;
          tabstop = 2;
          softtabstop = 2;

          number = true;
          numberwidth = 2;

          fillchars.eob = " ";

          termguicolors = true;
          wrap = false;
          cmdheight = 0;
          signcolumn = "yes";

          # go to previous/next line with h,l,left arrow and right arrow
          # when cursor reaches end/beginning of line
          whichwrap = "<>[]hl";

          winborder = "rounded";
        };

        keymaps = with config.utils.keymap; [
          # General bindings
          (mkMap "n" "<Esc>" "<cmd>noh<cr>" { desc = "Clear highlights"; })
          (mkMap "n" "<C-s>" "<cmd>w<cr>" { desc = "Write file"; })
          (mkMap "n" ";" ":" { })

          # Window navigation
          (mkMap "n" "<C-h>" "<C-w>h" { desc = "Switch window left"; })
          (mkMap "n" "<C-l>" "<C-w>l" { desc = "Switch window right"; })
          (mkMap "n" "<C-j>" "<C-w>j" { desc = "Switch window down"; })
          (mkMap "n" "<C-k>" "<C-w>k" { desc = "Switch window up"; })

          # Buffer navigation
          (mkMap "n" "<Tab>" "<cmd>bn<cr>" { desc = "Next buffer"; })
          (mkMap "n" "<S-Tab>" "<cmd>bp<cr>" { desc = "Previous buffer"; })
          (mkMap "n" "<leader>x" "<cmd>bp | bd #<cr>" { desc = "Close buffer"; })

          # Commenting
          (mkMap "n" "<leader>/" "gcc" {
            desc = "toggle comment";
            remap = true;
          })
          (mkMap "v" "<leader>/" "gc" {
            desc = "toggle comment";
            remap = true;
          })

          # Terminal escape
          (mkMap "t" "<Esc><Esc>" "<C-\\><C-n>" { desc = "Escape terminal"; })
        ];

        plugins = {
          web-devicons.enable = true;
        };

        utils = {
          keymap = {
            mkMap = mode: key: action: options: {
              inherit
                mode
                key
                action
                options
                ;
            };
          };
        };
      };
    };
}
