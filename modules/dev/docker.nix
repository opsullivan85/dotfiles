{ pkgs, ... }:

{
  # The daemon and the docker group are system-level (hosts/<name>/configuration.nix,
  # virtualisation.docker), so this unit only adds the client-side tools.
  home.packages = with pkgs; [
    lazydocker
    dive # explore image layers
  ];

  # Docker only finds compose and buildx as CLI plugins in ~/.docker/cli-plugins,
  # which is what makes `docker compose` and `docker buildx` work.
  home.file = {
    ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
    ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    ms-azuretools.vscode-containers
    ms-azuretools.vscode-docker
    ms-vscode-remote.remote-containers
  ];
}
