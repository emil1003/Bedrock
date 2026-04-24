{
  flake.homeModules."fastfetch" = _: {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo.type = "small";

        modules = [
          "title"
          {
            type = "separator";
            string = "─";
          }
          {
            type = "os";
            key = " ";
          }
          {
            type = "kernel";
            key = " ";
          }
          {
            type = "packages";
            key = " ";
          }
          {
            type = "shell";
            key = " ";
          }
          "break"
          {
            type = "host";
            key = "󰾰 ";
          }
          {
            type = "cpu";
            key = " ";
          }
          {
            type = "gpu";
            key = "󰢮 ";
          }
          {
            type = "memory";
            key = " ";
          }
          {
            type = "disk";
            key = " ";
          }
          "break"
        ];
      };
    };
  };
}
