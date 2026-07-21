{pkgs}: {version ? "20"}: let
  nodejsPackage = pkgs."nodejs_${version}";

  # Registry config only, no secrets: this file ends up in the Nix store,
  # which is world-readable, and is fetched as a plain tarball (bypassing any
  # git-crypt filters) whenever a project pulls this flake via `github:`.
  npmrcBase = pkgs.writeText "npmrc-base" ''
    prefix=~/.npm-global
    @finapi-internal:registry=https://repo.finapi.io/artifactory/api/npm/npm/
    @dev:registry=https://npm.finapi.ghe.com
  '';

  npmrcRuntime = "$HOME/.npm-global/.npmrc";
in {
  packages = with pkgs; [
    (
      # NPM wrapper that passes user config assembled at shell start.
      writeShellApplication
      {
        name = "npm";
        text = ''
          ${nodejsPackage}/bin/npm --userconfig "${npmrcRuntime}" "$@"
        '';
      }
    )
    nodejsPackage
  ];

  shellHook = ''
    if [ ! -d "$HOME/.npm-global" ]; then
      mkdir "$HOME/.npm-global"
      echo "Created ~/.npm-global"
    fi

    export PATH="$HOME/.npm-global/bin:$PATH"

    # Auth tokens live outside the repo entirely, in a per-machine file that
    # is never committed. Assembled fresh on every shell start so it always
    # reflects the latest local secret, and silently omitted if absent.
    {
      cat ${npmrcBase}
      [ -f "$HOME/.config/dev-toolkit-nix/npmrc-auth" ] && cat "$HOME/.config/dev-toolkit-nix/npmrc-auth"
    } > "${npmrcRuntime}"
  '';
}
