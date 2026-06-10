{pkgs}: (
  pkgs.writeShellApplication {
    name = "tags";
    text = ''
      git tag -l 'v0.*.0' --sort=-creatordate | head -n 10 | xargs -I {} git show --no-patch {}
    '';
  }
)
