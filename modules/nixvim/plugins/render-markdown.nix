{
  flake.nixvimModules."render-markdown" = _: {
    plugins.render-markdown = {
      enable = true;
    };
  };
}
