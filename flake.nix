#
# This flake will install several command line tools
# used by devs. How do I use this file, you ask?
#
# 1. Install the nix package manager.
#
#        sh <(curl -L https://nixos.org/nix/install) --no-daemon
#    
#    This may require a restart of your shell.    
#
# 2. Enable nix flakes and experimental tooling.
#
#        mkdir -p ~/.config/nix && \
#        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
#
# 3. Run `nix profile install .` to install the packages.
#

{
  description = "Base Developer Environment";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs@{ self, flake-parts, nixpkgs }:

    flake-parts.lib.mkFlake { inherit inputs; } {

      #
      # Here we can list the systems we are supporting
      #
      systems = [
        "x86_64-linux"
      ];

      perSystem = { pkgs, system, ... }: {
        packages = {

          #
          # buildEnv is a convenient derivation container for a list of packages.
          #
          base = pkgs.buildEnv {
            name = "dev-base";
            paths = with pkgs; [
              direnv
              git
              nix-direnv
              starship
            ];
          };

          #
          # In order to create a set of additonal packages
          # we can add an additional output here with a
          # similar structure to packages.base, named "extras".
          # We can then install it with "nix profile install 'githun:trinnex/dev-profile#extras'".
          #
          # extras = pkgs.buildEnv {
          #   name = "dev-extras";
          #   paths = with pkgs; [
          #     fzf
          #   ];
          # };
          
          #
          # packages.default must be set to a derivation
          #
          default = self.packages.${system}.base;
        };
      };
    };
}
