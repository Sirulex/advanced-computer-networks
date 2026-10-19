{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    containerlab.url = "github:srl-labs/containerlab";
  };

  outputs = { nixpkgs, containerlab, ... }: {
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
