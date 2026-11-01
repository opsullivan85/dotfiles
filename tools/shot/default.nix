{
  writeShellApplication,
  grim,
  jq,
  satty,
  slurp,
  wl-clipboard,
}:

writeShellApplication {
  name = "shot";
  runtimeInputs = [
    grim
    jq
    satty
    slurp
    wl-clipboard
  ];
  text = builtins.readFile ./shot.sh;
}
