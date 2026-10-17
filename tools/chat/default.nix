{ writeShellApplication }:

writeShellApplication {
  name = "chat";
  text = builtins.readFile ./chat.sh;
}
