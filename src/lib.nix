{
  pkgs,
  root,
}: let
  inherit (root) profileDefinitions;
in {
  buildDevShell = {
    profiles,
    name,
    extraPackages ? [],
    extraShellHook ? "",
  }: let
    # collect chose profile definitions
    profileList = (
      builtins.map
      (profile: {
        name = profile.name;
        definition = profileDefinitions.${profile.name} (
          if profile ? options
          then profile.options
          else {}
        );
      })
      profiles
    );

    # concat lists of packages from chosen profile definitions; if the defintion
    # doesn't have packages defined, treat it as empty list
    packages =
      builtins.concatLists (builtins.map (
          profile:
            if profile.definition ? packages
            then profile.definition.packages
            else []
        )
        profileList)
      ++ extraPackages;

    # concat shell hook strings from chosen definitions; each profile's shell
    # hook at least has echo of it's name; add default shell name echo at then
    # end
    shellHook = builtins.concatStringsSep "\n" ((builtins.map (
          profile: let
            loadedMessage = "echo \"Profile ${profile.name} loaded\"";
          in
            if profile.definition ? shellHook
            then profile.definition.shellHook + loadedMessage
            else loadedMessage
        )
        profileList)
      ++ [
        extraShellHook
        "echo \"DevShell ${name} started\""
      ]);
  in
    pkgs.mkShell {
      inherit name packages shellHook;
    };
}
