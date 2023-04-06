{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs:
    let
      inherit (inputs) nixpkgs flake-utils;
    in
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          defaultPackage = pkgs.buildEnv {
            name = "default profile";
            paths = with pkgs; [
              git
              direnv
              nix-direnv
            ];
          };
        }
      );
}
