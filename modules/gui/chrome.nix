{ pkgs, ... }:

{
  # Google Chrome on Linux rejects declarative extensions (Home Manager assertion),
  # so Bitwarden is installed by hand from the Web Store.
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };

  # Web links (`open`/xdg-open, other apps' links) go to Chrome.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
    };
  };
}
