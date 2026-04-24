{
  flake.homeModules."programs-graphical" =
    { pkgs, ... }:
    {
      programs = {
        mpv = {
          enable = true;
          config = {
            hwdec = "auto";
          };
        };

        streamlink = {
          enable = true;
          settings = {
            player = "${pkgs.mpv}/bin/mpv";
            player-args = "--geometry=1280x720 --volume=80 --no-cache";
          };
        };
      };
    };
}
