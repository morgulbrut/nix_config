{
  description = "Fixed flake for NixOS + home-manager + NVF";

  inputs = {
    # primary channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NVF (Neovim framework)
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Noctalia shell (Wayland desktop shell + launcher)
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";

  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      mkHost =
        {
          hostName,
          hmUser,
        }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/${hostName}

            # Home-Manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-back";
              home-manager.overwriteBackup = true;
              home-manager.extraSpecialArgs = {
                inherit inputs hostName;
              };
              home-manager.users = {
                "${hmUser}" = import ./hosts/${hostName}/home.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        osgiliath = mkHost {
          hostName = "osgiliath";
          hmUser = "tillo";
        };
      };
    };
}
