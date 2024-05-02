{pkgs}: {
  packages = with pkgs; [
    (
      let
        npmrc =
          # The nix store is not writable, therefore we must instruct npm to
          # use different folder for the global packages,
          pkgs.writeText "npmrc" ''
            prefix=~/.npm-global
            @finapi-internal:registry=https://repo.finapi.io/artifactory/api/npm/npm/

            # Place following to the project's .npmrc
            # init-author-name=<name>
            # email=<email>
            # //registry.npmjs.org/:_authToken=<authToken>
            # //repo.finapi.io/artifactory/api/npm/npm/:_auth="<authToken>"
          '';
      in
        # NPM wrapper that passes user config stored in nix store. To avoid
        # name collision, it is named just `f` (the home key of index finger).
        pkgs.writeShellApplication
        {
          name = "npm";
          text = ''
            ${pkgs.nodejs-18_x}/bin/npm --userconfig ${npmrc} "$@"
          '';
        }
    )
    nodejs-18_x
  ];

  shellHook = ''
    if [ ! -d "$HOME/.npm-global" ]; then
      mkdir "$HOME/.npm-global"
      echo "Created ~/.npm-global"
    fi

    export PATH="$HOME/.npm-global/bin:$PATH"
  '';
}
