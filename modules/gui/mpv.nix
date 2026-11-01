{ pkgs, ... }:

let
  videoTypes = [
    "video/mp4"
    "video/webm"
    "video/x-matroska"
    "video/quicktime"
    "video/x-msvideo"
  ];
in
{
  home.packages = [ pkgs.mpv ];

  # `open` (xdg-open) sends videos to mpv instead of the browser.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      map (t: {
        name = t;
        value = "mpv.desktop";
      }) videoTypes
    );
  };
}
