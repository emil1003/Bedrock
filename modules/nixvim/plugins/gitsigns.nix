{
  flake.nixvimModules."gitsigns" =
    { config, ... }:
    {
      plugins.gitsigns = {
        enable = true;
      };

      keymaps =
        let
          gitsigns = ''require("gitsigns")'';
        in
        with config.utils.keymap;
        [
          # General
          (mkMap "n" "<leader>gb" { __raw = "${gitsigns}.blame"; } { desc = "Git blame (window)"; })

          # Staging operations
          (mkMap "n" "<leader>gs" { __raw = "${gitsigns}.stage_hunk"; } { desc = "Git stage hunk"; })
          (mkMap "n" "<leader>gr" { __raw = "${gitsigns}.reset_hunk"; } { desc = "Git reset hunk"; })

          (mkMap "v" "<leader>gs" {
            __raw = ''function() ${gitsigns}.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end'';
          } { desc = "Git stage lines"; })

          (mkMap "v" "<leader>gr" {
            __raw = ''function() ${gitsigns}.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end'';
          } { desc = "Git reset lines"; })

          (mkMap "n" "<leader>gS" { __raw = "${gitsigns}.stage_buffer"; } { desc = "Git stage buffer"; })
          (mkMap "n" "<leader>gR" { __raw = "${gitsigns}.reset_buffer"; } { desc = "Git reset buffer"; })
        ];
    };
}
