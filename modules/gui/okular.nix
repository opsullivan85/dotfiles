{ pkgs, ... }:

{
  home.packages = [ pkgs.kdePackages.okular ];

  # `open` (xdg-open) sends documents to Okular instead of the browser.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "okularApplication_pdf.desktop";
      "application/epub+zip" = "okularApplication_epub.desktop";
      "image/vnd.djvu" = "okularApplication_djvu.desktop";
    };
  };
}
