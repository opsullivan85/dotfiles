{ pkgs, ... }:

{
  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      inferrinizzard.prettier-sql-vscode
      cweijan.dbclient-jdbc
      (pkgs.vscode-utils.extensionFromVscodeMarketplace {
        publisher = "cweijan";
        name = "vscode-postgresql-client2";
        version = "9.0.2";
        sha256 = "sha256-BmcVzL8DV3E+oZ/ciIwChbzT/1kdXkovZ60nii09jfw=";
      })
    ];
    userSettings."[sql]"."editor.defaultFormatter" = "inferrinizzard.prettier-sql-vscode";
  };
}
