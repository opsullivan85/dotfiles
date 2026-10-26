{ ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo.source = "none";
      display = {
        color = "blue";
        separator = "  ";
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "terminal"
        "break"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "break"
        {
          type = "command";
          key = "jn todo";
          keyColor = "yellow";
          # One line per incomplete `- [ ]` task across all jn notes,
          # numbered and joined so it doesn't break fastfetch's layout.
          text = ''
            rg --no-heading --no-filename -N '^\s*- \[ \] ' ~/Documents/jn 2>/dev/null \
              | sed -E 's/^- \[ \] //' \
              | awk '{printf "%d) %s  ", NR, $0} END{if (NR==0) print "none"}'
          '';
        }
      ];
    };
  };
}
