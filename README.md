# dotfiles

Flake-based configuration for my machines: a NixOS laptop running niri
(PaperWM-style scrolling tiling) with the Noctalia shell, plus standalone
home-manager modules that a separate private repo reuses for the Ubuntu work laptop
(see [docs/private-work.md](docs/private-work.md)). One theme, defined once, drives all of it.

## Layout

```
flake.nix            outputs: nixosConfigurations, homeModules, lib.mkHome, devShell, formatter
theme.nix            single source of truth: colour scheme, polarity, mono font
hosts/laptop/        NixOS system config (things that need root: greetd, udev, pipewire…)
modules/             one file per tool, grouped by kind, opted into per machine:
  terminal/          zsh (+p10k), tmux
  cli/               git, gh, tldr, home-manager
  tui/               btop, keifu, claude-code, chat
  gui/               brave, pqiv
  dev/               NvChad, plus one file per language (python, rust, godot…)
tools/               our own CLI tools, one dir each (bash, Python, Rust…), built by Nix;
                     `nix run .#<name>` to try one, install via a wrapper in modules/
home/                home-manager glue that isn't a single tool:
  os/nixos/          graphical stuff that only exists on NixOS: niri, Noctalia, Stylix
  os/ubuntu/         non-NixOS glue (targets.genericLinux)
  profiles/          personal.nix: identity (the work profile lives in the private repo)
  machines/          one file per machine, picking os + profile + the modules it wants
nvim/                NvChad additions (plugins.lua, lazy-lock.json), applied via nix4nvchad
switch, bootstrap    the two scripts you run (Python, stdlib only)
scripts/             helpers (in-devshell)
dotlib/              shared UI code for the scripts
```

A machine is `os/<x> + profiles/<y>` plus whichever `modules/*` its file imports.
To drop a tool from one machine, delete its import line in `home/machines/`.
Every module is also exported as `homeModules.<category>-<name>` (e.g. `dev-rust`).

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

On a non-NixOS machine pass `--target <flake output>`; the work laptop is built from the private repo instead.

## New machine

1. Install Nix with flakes enabled (NixOS has it; elsewhere use the Determinate or official installer).
2. `git clone <repo> ~/dotfiles` (the `rebuild` alias and docs assume this path).
3. NixOS: `sudo nixos-rebuild switch --flake ~/dotfiles#laptop`.
   Ubuntu work laptop: see [docs/private-work.md](docs/private-work.md).
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

Things that need keeping in sync by hand:

- **NvChad theme**: `nvchadTheme` in `theme.nix` must match `base16Scheme` (NvChad doesn't read base16).
- **Noctalia GUI changes** are written to `~/.local/state/noctalia/settings.toml`;
  copy anything you want to keep into `home/os/nixos/noctalia.nix`.
