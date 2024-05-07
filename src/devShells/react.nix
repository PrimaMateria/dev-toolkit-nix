{root}:
root.lib.buildDevShell {
  name = "Generic React Shell";
  profiles = [
    "wsl"
    "node"
    "jest"
    "playwright"
  ];
}
