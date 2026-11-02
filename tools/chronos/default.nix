{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "chronos";
  version = "unstable-2026-09-25";

  src = fetchFromGitHub {
    owner = "samuelstranges";
    repo = "chronos";
    rev = "af74fc3e9e32cfc1a0a07e59728992c80a9747b7";
    hash = "sha256-WK9iUbBgab3CWm3aoVE8YwhNjWu48ADIeWZQReFr4h0=";
  };

  patches = [ ./12-hour-time.diff ];

  vendorHash = "sha256-9Y+ni/48niSNvYy50bleJmfBGWozLLu8efHQf0EZfFs=";
}
