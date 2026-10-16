{ config, pkgs, theme, ... }:

{
  imports =
    [ ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Wayland session: niri (scrolling tiling compositor), launched from a
  # TTY-based greeter rather than GDM/GNOME.
  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Lets greetd's PAM stack unlock (and, if missing, create) the login
  # keyring using your login password, instead of leaving gnome-keyring
  # running but locked and prompting separately.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.printing.enable = true;

  # Built-in panel brightness: brightnessctl ships udev rules that make the
  # backlight writable by the "video" group (so no sudo needed).
  services.udev.packages = [ pkgs.brightnessctl ];

  # Noctalia (desktop shell on top of niri) wants these for its
  # wifi/bluetooth/power/battery widgets.
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # System-level zsh registers it in /etc/shells; home-manager's programs.zsh
  # (home/core/zsh.nix) handles the actual rc content/plugins.
  programs.zsh.enable = true;

  users.users."owen" = {
    isNormalUser = true;
    description = "Owen";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  # NvChad's docs recommend this specific font (not the "Mono" variant —
  # icons render smaller with that one) for its file/status icons.
  fonts.packages = [ theme.monoFont.package ];

  # Theme itself is defined once in theme.nix (see flake.nix for how it's
  # threaded through). Noctalia's stylix target is disabled in
  # home/os/nixos/noctalia.nix instead — it's a home-manager-scoped target, not a
  # NixOS one, so it has to be set there. There's no stylix target for
  # plain neovim (only "nixvim"/"nvf", for Nix-DSL configs) — irrelevant
  # here since NvChad owns ~/.config/nvim entirely outside Nix anyway.
  stylix.base16Scheme = theme.base16Scheme;
  stylix.polarity = theme.polarity;
  stylix.fonts.monospace = theme.monoFont;

  # Prebuilt Noctalia binaries instead of compiling its C++/Qt core locally.
  nix.settings = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  # Kept to the minimum you'd want even if home-manager were completely
  # broken. Everything else (btop, claude-code, git, zsh, tmux, nvim deps)
  # lives in home/.
  environment.systemPackages = with pkgs; [
    vim
    wget
    brightnessctl
  ];

  system.stateVersion = "26.05";
}
