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

      devSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      makeDevEnv = system: rec {
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };

        lostless = import ./services/lostless/dev {
          type = "dev";
          filebrowserSha = "sha256-Lrr9towIexbUgaX/ItRAH5Mk8XI3fhjjVyN/egIXWV4=";
          withCloudflared = false;
          inherit pkgs;
        };

        composeFile = lostless.mkComposeFile "./dev-storage";

        initService =
          # bash
          ''
            if [ ! -d "./dev-storage" ]; then
                mkdir -p "./dev-storage"
            fi
            ${pkgs.docker}/bin/docker load < ${lostless.filebrowserDockerfile}
            cat ${composeFile} > compose.yml
          '';
      };

    in

    {
      nixosConfigurations = builtins.listToAttrs (map mkHost hostNames);

      apps = nixpkgs.lib.genAttrs devSystems (
        system:
        let
          devEnv = makeDevEnv system;
        in
        with devEnv;
        {
          default = {
            type = "app";
            program = "${
              pkgs.writeShellScriptBin "start-lostless" (
                initService
                +
                  #bash
                  ''
                    ${pkgs.docker}/bin/docker compose down
                    ${pkgs.docker}/bin/docker compose -p lostless up
                  ''
              )
            }/bin/start-lostless";
          };
        }
      );

      devShells = nixpkgs.lib.genAttrs devSystems (
        system:
        let
          devEnv = makeDevEnv system;
        in
        with devEnv;
        {
          default = pkgs.mkShell {
            packages = import ./system/packages.nix { inherit pkgs; };
            shellHook = initService;
          };
        }
      );
    };

}
