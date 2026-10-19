{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    containerlab.url = "github:srl-labs/containerlab";
  };

  outputs = { nixpkgs, containerlab, ... }: {
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = [
            containerlab.packages.${system}.default
            pkgs.docker
          ];

          shellHook = ''
            if [ -z "''${DOCKER_HOST:-}" ] && [ -n "''${XDG_RUNTIME_DIR:-}" ]; then
              export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
            fi
          '';
        };
      });

    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        containerlab.nixosModules.default
        {
          virtualisation.docker.rootless = {
            enable = true;
            setSocketVariable = true;
          };

          programs.containerlab.enable = true;
          users.users.alice.extraGroups = [ "clab_admins" ];
        }
      ];
    };
  };
}
