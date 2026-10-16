{ config, pkgs, ... }:

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
  # (home/zsh.nix) handles the actual rc content/plugins.
  programs.zsh.enable = true;

  users.users."owen" = {
    isNormalUser = true;
    description = "Owen";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  # NvChad's docs recommend this specific font (not the "Mono" variant —
  # icons render smaller with that one) for its file/status icons.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

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
  ];

  system.stateVersion = "26.05";
}
