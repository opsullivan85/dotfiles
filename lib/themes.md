# Theme combinations

Schemes that exist in all three of base16 (`pkgs.base16-schemes`, drives Stylix, the
terminal, tmux and p10k), NvChad (base46) and VS Code. Use with `scripts/rebuild --theme`
(see `lib/theme.nix`); each row's command sets all three explicitly because the automatic
guesses (NvChad name = scheme name with `-` as `_`; light only if the name says "light")
are wrong for most of them.

VS Code themes are not part of Stylix: the theme only applies if its extension is
installed. Only the built-in ones work today; for the others add the extension (nixpkgs
attribute in the last column) to `profiles.default.extensions` in `modules/gui/vscode.nix`,
otherwise VS Code silently keeps its previous theme.

| Family | Variant | base16 scheme | NvChad | VS Code | VS Code source |
| --- | --- | --- | --- | --- | --- |
| Gruvbox | dark | `gruvbox-dark-hard` | `gruvbox` | `Gruvbox Dark Hard` | `jdinhlife.gruvbox` |
| Gruvbox | light | `gruvbox-light-hard` | `gruvbox_light` | `Gruvbox Light Hard` | `jdinhlife.gruvbox` |
| Catppuccin | dark | `catppuccin-mocha` | `catppuccin` | `Catppuccin Mocha` | `catppuccin.catppuccin-vsc` |
| Catppuccin | light | `catppuccin-latte` | `catppuccin-latte` | `Catppuccin Latte` | `catppuccin.catppuccin-vsc` |
| Rosé Pine | dark | `rose-pine` | `rosepine` | `Rosé Pine` | `mvllow.rose-pine` |
| Rosé Pine | light | `rose-pine-dawn` | `rosepine-dawn` | `Rosé Pine Dawn` | `mvllow.rose-pine` |
| Solarized | dark | `solarized-dark` | `solarized_dark` | `Solarized Dark` | built in |
| Solarized | light | `solarized-light` | `solarized_light` | `Solarized Light` | built in |
| GitHub | dark | `github-dark` | `github_dark` | `GitHub Dark Default` | `github.github-vscode-theme` |
| GitHub | light | `github` | `github_light` | `GitHub Light Default` | `github.github-vscode-theme` |
| One Dark / Light | dark | `onedark` | `onedark` | `One Dark Pro` | `zhuangtongfa.material-theme` |
| Tokyo Night | dark | `tokyo-night-dark` | `tokyonight` | `Tokyo Night` | `enkia.tokyo-night` |
| Nord | dark | `nord` | `nord` | `Nord` | `arcticicestudio.nord-visual-studio-code` |

Commands (VS Code theme names are the extension's labels, checked against the nixpkgs
packages):

```
scripts/rebuild --theme catppuccin-mocha --variant dark  --nvchad catppuccin       --vscode "Catppuccin Mocha"
scripts/rebuild --theme catppuccin-latte --variant light --nvchad catppuccin-latte --vscode "Catppuccin Latte"
scripts/rebuild --theme rose-pine        --variant dark  --nvchad rosepine         --vscode "Rosé Pine"
scripts/rebuild --theme rose-pine-dawn   --variant light --nvchad rosepine-dawn    --vscode "Rosé Pine Dawn"
scripts/rebuild --theme solarized-dark   --variant dark  --nvchad solarized_dark   --vscode "Solarized Dark"
scripts/rebuild --theme solarized-light  --variant light --nvchad solarized_light  --vscode "Solarized Light"
scripts/rebuild --theme github-dark      --variant dark  --nvchad github_dark      --vscode "GitHub Dark Default"
scripts/rebuild --theme github           --variant light --nvchad github_light     --vscode "GitHub Light Default"
scripts/rebuild --theme onedark          --variant dark  --nvchad onedark          --vscode "One Dark Pro"
scripts/rebuild --theme tokyo-night-dark --variant dark  --nvchad tokyonight       --vscode "Tokyo Night"
scripts/rebuild --theme nord             --variant dark  --nvchad nord             --vscode "Nord"
scripts/rebuild --theme gruvbox-dark-hard --variant dark --nvchad gruvbox          --vscode "Gruvbox Dark Hard"
```

## Near misses (a base16 scheme and an NvChad theme, but no VS Code extension in nixpkgs)

Works for everything except VS Code, which would need `--vscode "Dark Modern"` (or "Light Modern"):

- Everforest: `everforest-dark-hard` / `everforest` (base16 has no light variant)
- Kanagawa: `kanagawa` / `kanagawa`
- Ayu: `ayu-dark` / `ayu_dark`, `ayu-light` / `ayu_light`
- Flexoki: `flexoki-dark` / `flexoki`, `flexoki-light` / `flexoki-light`
- Material: `material-darker` / `material-darker`, `material-lighter` / `material-lighter`
- Oxocarbon: `oxocarbon-dark` / `oxocarbon`
- Mountain, Vesper, Zenburn, Jabuti: same name in both
