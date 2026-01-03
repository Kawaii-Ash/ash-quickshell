{ version ? "dev"
, lib
, stdenvNoCC
, qt6
, quickshell
, ... }: let
  src = lib.cleanSourceWith {
    src = ../.;
    # Drop VCS, packaging files, and the nix/ folder from the build context
    filter = path: type:
      let
        name = builtins.baseNameOf path;
        excluded = [ ".git" ".gitignore" ".envrc" ".direnv" "nix" "flake.nix" "flake.lock" ];
      in
      ! (lib.elem name excluded);
  };
in
stdenvNoCC.mkDerivation {
  pname = "ash-quickshell";
  inherit version src;

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  buildInputs = [ qt6.qtbase ];

  installPhase = ''
    mkdir -p $out/share/ash-quickshell $out/bin
    cp -r . $out/share/ash-quickshell
    ln -s ${quickshell}/bin/qs $out/bin/ash-quickshell
  '';

  preFixup = ''
    qtWrapperArgs+=(
    --add-flags "-p $out/share/ash-quickshell"
    )
  '';

  meta = {
    description = "Ash's Quickshell configuration";
    mainProgram = "ash-quickshell";
  };
}
