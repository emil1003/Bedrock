{
  flake.homeModules."git" = _: {
    programs.git = {
      enable = true;
      settings = {
        advice = {
          detachedHead = false;
        };

        alias = {
          b = "branch -vv";
          pr = "pull --rebase";
          s = "status";
        };

        core = {
          abbrev = 12;
        };

        init = {
          defaultBranch = "main";
        };
      };
    };
  };
}
