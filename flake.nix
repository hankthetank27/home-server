{
  description = "Homeserver System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          host = import ./system/hosts/lostless-prod;
        in
        with host;
        {
          nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs storagePath;
            };
            modules = [
              home-manager.nixosModules.home-manager
              ./system/configuration.nix
              hardwareConfig
            ];
          };
        };
    };
}
