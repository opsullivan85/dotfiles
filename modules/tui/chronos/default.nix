{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.chronos.remoteIcs;

  refreshRemoteCalendar = pkgs.writeShellApplication {
    name = "chronos-refresh-remote-calendar";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.gnugrep
    ];
    text = ''
      url_file=${lib.escapeShellArg (if cfg.urlFile == null then "" else cfg.urlFile)}
      calendar_file=${lib.escapeShellArg "${config.xdg.configHome}/chronos/calendars/outlook.ics"}

      if [[ -z "$url_file" ]]; then
        printf 'Set programs.chronos.remoteIcs.urlFile to the path of a file containing the HTTPS ICS URL\n' >&2
        exit 1
      fi

      if [[ ! -r "$url_file" ]]; then
        printf 'Chronos ICS URL file is not readable: %s\n' "$url_file" >&2
        exit 1
      fi

      url="$(< "$url_file")"
      if [[ -z "$url" || "$url" != https://* || "$url" == *$'\n'* ]]; then
        printf 'Chronos ICS URL file must contain one HTTPS URL\n' >&2
        exit 1
      fi

      mkdir -p -- "$(dirname -- "$calendar_file")"
      temp_file="$(mktemp "''${calendar_file}.XXXXXX")"
      trap 'rm -f -- "$temp_file"' EXIT

      curl \
        --proto '=https' \
        --proto-redir '=https' \
        --fail \
        --location \
        --silent \
        --show-error \
        --connect-timeout 15 \
        --max-time 60 \
        --output "$temp_file" \
        "$url"

      if ! grep --quiet --fixed-strings 'BEGIN:VCALENDAR' "$temp_file"; then
        printf 'Downloaded file is not an iCalendar feed\n' >&2
        exit 1
      fi

      chmod 600 "$temp_file"
      mv -- "$temp_file" "$calendar_file"
    '';
  };

  cal = pkgs.writeShellApplication {
    name = "cal";
    runtimeInputs = [
      inputs.self.packages.${pkgs.system}.chronos
      refreshRemoteCalendar
    ];
    text = ''
      if [[ "''${1:-}" == fetch ]]; then
        if (( $# != 1 )); then
          printf 'Usage: cal fetch\n' >&2
          exit 2
        fi
        exec chronos-refresh-remote-calendar
      fi

      exec chronos "$@"
    '';
  };
in
{
  options.programs.chronos.remoteIcs.urlFile = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "/run/secrets/outlook-calendar-url";
    description = ''
      Path to a local file containing the HTTPS ICS URL. Keep the URL out of
      Nix configuration and the Nix store. When set, Chronos downloads the
      feed to its Outlook calendar once after login and then hourly.
    '';
  };

  config = {
    home.packages = [
      inputs.self.packages.${pkgs.system}.chronos
      cal
    ];

    systemd.user.services.chronos-remote-ics = lib.mkIf (cfg.urlFile != null) {
      Unit.Description = "Refresh the remote ICS calendar for Chronos";
      Service = {
        Type = "oneshot";
        ExecStart = "${refreshRemoteCalendar}/bin/chronos-refresh-remote-calendar";
      };
    };

    systemd.user.timers.chronos-remote-ics = lib.mkIf (cfg.urlFile != null) {
      Unit.Description = "Refresh the remote ICS calendar for Chronos hourly";
      Timer = {
        OnBootSec = "5m";
        OnUnitActiveSec = "1h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
