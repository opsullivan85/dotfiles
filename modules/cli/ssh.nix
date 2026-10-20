{
  # Client config only (hosts, agent); not imported on the NixOS laptop.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*".AddKeysToAgent = "yes";
  };
}
