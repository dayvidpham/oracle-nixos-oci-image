{
  description = "Builds an OCI image for aarch64, to run on Oracle Cloud Infrastructure";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-stable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs =
    inputs@{ self
    , nixpkgs-unstable
    , nixpkgs-stable
    , home-manager
    , nix-index-database
    , ...
    }:
    let
      # NOTE: Most of this referenced from:
      # https://github.com/LGUG2Z/nixos-hetzner-cloud-starter/blob/bce8552526931a1de81f19e845ccfe0017b729a7/flake.nix
      nixpkgsWithOverlays = (system: (import nixpkgs-stable rec {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # FIXME:: add any insecure packages you absolutely need here
          ];
        };

        overlays = [
          (_final: prev: {
            # this allows us to reference pkgs.unstable
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
          })
        ];
      }));

      hmConfigDefaults = args: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      specialArgsDefaults = {
        inherit inputs self nix-index-database;
        channels = {
          nixpkgs = nixpkgs-stable;
          inherit nixpkgs-unstable;
        };
      };

      mkNixosConfiguration =
        (system: pkgs: { hostname
                       , username
                       , customSpecialArgs ? { }
                       , modules
                       ,
                       }:
          let
            specialArgs = specialArgsDefaults
              // { inherit hostname username; }
              // customSpecialArgs;
          in
          nixpkgs-stable.lib.nixosSystem {
            inherit system specialArgs pkgs;
            modules = [
              (hmConfigDefaults specialArgs)
              home-manager.nixosModules.home-manager
            ] ++ modules;
          });

      ##########################
      # My changes
      inherit (builtins)
        map
        mapAttrs
        foldl'
        hasAttr
        head
        ;

      defaultSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forSystems =
        (mkOutput: systems: mkOutputArgs:
          let
            systemOutputs =
              (map
                (system: mkOutput system mkOutputArgs)
                systems);
          in
          foldl'
            (output: acc:
              (mapAttrs
                (name: value:
                  if (hasAttr name acc)
                  then value // acc.${name}
                  else value)
                output
              ))
            (if (systemOutputs == [ ])
            then { }
            else (head systemOutputs))
            systemOutputs
        );

      createSystemOutput =
        (system: { username
                 , hostname
                 , customSpecialArgs ? { }
                 , modules
                 ,
                 }@mkOutputArgs:
          let
            pkgs = nixpkgsWithOverlays system;

            flakeOutput = {
              formatter.default = pkgs.nixpkgs-fmt;
              nixosConfigurations."oracle-${system}" =
                mkNixosConfiguration system pkgs mkOutputArgs;
            };
          in
          mapAttrs
            (name: value:
              if (name == "nixosConfigurations")
              then value
              else {
                "${system}" = value;
              })
            flakeOutput);

      mkOutputArgs = {
        hostname = "oracle";
        username = "minttea";
        modules = [
          #disko.nixosModules.disko
          ./oracle.nix
          ./linux.nix
        ];
      };
    in
    forSystems createSystemOutput defaultSystems mkOutputArgs;
}
