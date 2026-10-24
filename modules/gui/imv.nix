{ pkgs, ... }:

let
  imageTypes = [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heic"
    "image/jpeg"
    "image/png"
    "image/svg+xml"
    "image/tiff"
    "image/webp"
  ];
in
{
  home.packages = [ pkgs.imv ];

  # `open` (xdg-open) sends images to imv instead of the browser.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      map (t: {
        name = t;
        value = "imv.desktop";
      }) imageTypes
    );
  };
}
