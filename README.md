# dotfiles

Flake-based configuration for my machines: a NixOS laptop running niri
(PaperWM-style scrolling tiling) with the Noctalia shell, plus standalone
home-manager on an Ubuntu work laptop. One theme, defined once, drives all of it.

## Layout

```
flake.nix            outputs: nixosConfigurations, homeConfigurations, devShell, formatter
theme.nix            single source of truth: colour scheme, polarity, mono font
hosts/laptop/        NixOS system config (things that need root: greetd, udev, pipewire…)
home/                home-manager config, composed in layers:
  core/              portable shell/dev environment: zsh, tmux, nvim link, dev/ toolchains
  os/nixos/          graphical stuff that only exists on NixOS: niri, Noctalia, Stylix
  os/ubuntu/         non-NixOS glue (targets.genericLinux)
  profiles/          personal.nix, work.nix: identity and apps per hat
  machines/          one file per machine, picking core + os + profile
nvim/                NvChad config, symlinked to ~/.config/nvim (not managed by Nix)
switch, bootstrap    the two scripts you run (Python, stdlib only)
scripts/             helpers (in-devshell)
dotlib/              shared UI code for the scripts
```

A machine is `core + os/<x> + profiles/<y>`. For example
`home/machines/personal-laptop.nix` is core + nixos + personal.

## Daily use

```sh
./switch                 # stage, check, rebuild, commit  (alias: rebuild)
./switch "add tmux bar"  # same, with a commit message
./switch -n              # rebuild without committing
./switch -v              # stream the full Nix output
```

`switch` keeps the terminal quiet: a spinner while building, then a summary of
what changed. Full output goes to `~/.local/state/dotfiles/logs/switch-latest.log`
(outside the repo); on failure you get just the error and the log path.
It commits only if the build succeeded, so history contains only configs that work.

On the Ubuntu laptop `switch` runs `home-manager switch --flake .#owen@work-laptop`.

## New machine

1. Install Nix with flakes enabled (NixOS has it; elsewhere use the Determinate or official installer).
2. `git clone <repo> ~/dotfiles` — it must live at `~/dotfiles` (the nvim symlink assumes it).
3. NixOS: `sudo nixos-rebuild switch --flake ~/dotfiles#laptop`.
   Ubuntu: `nix run home-manager -- switch --flake ~/dotfiles#owen@work-laptop`.
4. `./bootstrap` for the parts Nix doesn't own: git hooks, Rust toolchain, `gh auth login`.

## Development

`nix develop` provides the tools; hooks run them via `scripts/in-devshell`, so you
don't need to enter the shell yourself. Hooks are installed by `./bootstrap`.

| Check | Scope |
| --- | --- |
| nixfmt, statix, deadnix | `*.nix` (except the generated hardware config) |
| ruff (check + format) | `switch`, `bootstrap`, `dotlib/` |
| stylua | `nvim/` |
| shellcheck | shell scripts |
| `nix flake check` | on `git push` only (slower) |

`nix fmt` formats all Nix files.

## Manual sync points

Two things deliberately live outside Nix and need copying by hand:

- **NvChad theme**: `nvim/lua/chadrc.lua` must match `theme.nix`.
- **Noctalia GUI changes** are written to `~/.local/state/noctalia/settings.toml`;
  copy anything you want to keep into `home/os/nixos/noctalia.nix`.
