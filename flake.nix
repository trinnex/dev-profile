#
# This flake will represents our home profile.
# The packages listed in this flake will be available for your current user acount only.
# 
# TODO Talk about vscode and the remoting extension and windows terminal and the fonts (move this stuff to the README)
#
# 1. Install the nix package manager -- Pre-requisites are curl, wget, and xz(-utils).
#
#        sh <(curl -L https://nixos.org/nix/install) --no-daemon
#    
#    This may require a restart of your shell.    
#
# 2. Enable nix flakes and experimental tooling.
#
#        mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
#
# 3. Run `nix profile install github:trinnex/dev-profile` from your home directory to install the packages.
#

{
  description = "Base Developer Environment";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  # TODO Pin nix packages to recent master commit

  outputs = inputs@{ self, flake-parts, nixpkgs }:

    flake-parts.lib.mkFlake { inherit inputs; } {

      #
      # The systems we are supporting
      #
      systems = [
        "x86_64-linux"
      ];

      perSystem = { pkgs, system, ... }: {
        packages = {

          #
          # buildEnv is a convenient container for a list of packages.
          # Modify the paths list to add more packages to your shell
          #
          base = pkgs.buildEnv {
            name = "dev-base";
            paths = with pkgs; [
              # 👇 Add your packages here (search for them at https://search.nixos.org/packages [choose unstable])
              bat
              direnv
              exa
              git
              nix-direnv
              starship
              
            ];
          };
          
          #
          # packages.default must be set to a derivation
          #
          default = self.packages.${system}.base;
        };

        #
        # This is a convient way to ship a shell script within a flake.
        # To run this script simply execute 'nix run' from the same directory as this flake.
        # This is required as nix does not modify any user or system files itself
        # TODO Add aliases
        #
        apps.default = {
          type = "app";
          program = toString (pkgs.writeShellScript "setup" ''
              direnv_bash='eval "$(direnv hook bash)"'
              direnv_zsh='eval "$(direnv hook zsh)"'
              starship_bash='eval "$(starship init bash)"'
              starship_zsh='eval "$(starship init zsh)"'

              for i in .bash_profile .bash_login .profile .bashrc; do
                  fn="$HOME/$i"
                  if [ -w "$fn" ]; then
                      if ! grep -q "$direnv_bash" "$fn"; then
                          echo "modifying $fn for direnv..." >&2
                          printf '\n%s\n' "$direnv_bash" >> "$fn"
                      fi
                      if ! grep -q "$starship_bash" "$fn"; then
                          echo "modifying $fn for starship..." >&2
                          printf '\n%s\n' "$starship_bash" >> "$fn"
                      fi
                      break
                  fi
              done
              for i in .zshenv .zshrc; do
                  fn="$HOME/$i"
                  if [ -w "$fn" ]; then
                      if ! grep -q "$direnv_zsh" "$fn"; then
                          echo "modifying $fn for direnv..." >&2
                          printf '\n%s\n' "$direnv_zsh" >> "$fn"
                      fi
                      if ! grep -q "$starship_zsh" "$fn"; then
                          echo "modifying $fn for starship..." >&2
                          printf '\n%s\n' "$starship_zsh" >> "$fn"
                      fi
                      break
                  fi
              done

              direnvrc="$HOME/.config/direnv/direnvrc"
              nix_direnv="source $HOME/.nix-profile/share/nix-direnv/direnvrc"
              if [ -w "$direnvrc" ]; then
                  if ! grep -q "$nix_direnv" "$direnvrc"; then
                      echo "modifying $direnvrc for nix-direnv..."
                      echo "$nix_direnv" >> "$HOME/.config/direnv/direnvrc"
                  fi
              else
                  echo "creating $direnvrc for nix-direnv..."
                  mkdir -p "$HOME/.config/direnv"
                  echo "$nix_direnv" >> "$HOME/.config/direnv/direnvrc"
              fi

              echo "Please restart your shell for changes to take effect"
          '');
        };
      };
    };
}
