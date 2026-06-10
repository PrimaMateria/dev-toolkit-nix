{root}:
root.lib.buildDevShell {
  name = "Generic C Shell";
  profiles = [
    {name = "wsl";}
    {name = "c";}
  ];
}
