{
  description = "lostless.cafe server";

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
    let
      hostNames = builtins.attrNames (builtins.readDir ./system/hosts);

      mkHost =
        hostName:
        let
          host = import ./system/hosts/${hostName};
        in
        {
          name = host.hostName;
          value = nixpkgs.lib.nixosSystem (
            with host;
            {
              inherit system;
              specialArgs = {
                inherit
                  inputs
                  storagePath
                  sopsAgeKey
                  userName
                  userDesc
                  ;
              };
              modules = [
                home-manager.nixosModules.home-manager
                ./system/configuration.nix
                hardwareConfig
              ];
            }
          );
        };
    in
    {
      nixosConfigurations = builtins.listToAttrs (map mkHost hostNames);
    };
}
