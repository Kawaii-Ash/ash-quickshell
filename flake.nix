{
  description = "ash-quickshell with qml-niri plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    qml-niri = {
      url = "github:juuyokka/qml-niri/feat-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, qml-niri }:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      eachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = eachSystem (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        });
    in {
      devShells = eachSystem (system:
        let
          pkgs = pkgsFor.${system};
          quickshell-niri = qml-niri.packages.${system}.quickshell;
        in {
          default = pkgs.mkShell {
            name = "pbar-devshell";
            packages = [
              quickshell-niri
            ];

            shellHook = ''
              echo "DevShell ready: quickshell-niri available."
            '';
          };
        });

      packages = eachSystem (system:
        let pkgs = pkgsFor.${system}; in {
          ash-quickshell = pkgs.ash-quickshell;
          default = pkgs.ash-quickshell;
        });

      overlays = {
        default = final: prev: {
          ash-quickshell = final.callPackage ./nix/package.nix {
            version = "0.1.0";
            quickshell = qml-niri.packages.${final.stdenv.hostPlatform.system}.quickshell;
          };
        };
      };
    };
}
