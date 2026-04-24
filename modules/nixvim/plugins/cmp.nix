{
  flake.nixvimModules."cmp" = _: {
    plugins.cmp = {
      enable = true;

      settings = {
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };

        sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "async_path"; }
        ];

        window = {
          completion = {
            # border = "single";
            winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder";
          };
          documentation = {
            # border = "single";
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder";
          };
        };
      };
    };
  };
}
