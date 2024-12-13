{root}:
root.lib.buildDevShell {
  name = "Generic React Shell";
  profiles = [
    {name = "wsl";}
    {name = "node";}
    {name = "jest";}
  ];
}
