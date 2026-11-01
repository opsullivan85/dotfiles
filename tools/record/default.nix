{
  writeShellApplication,
  jq,
  libnotify,
  slurp,
  wf-recorder,
}:

writeShellApplication {
  name = "record";
  runtimeInputs = [
    jq
    libnotify
    slurp
    wf-recorder
  ];
  text = builtins.readFile ./record.sh;
}
