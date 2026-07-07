{
  description = "The whole kit n kaboodle";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-managerU = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-managerS = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixpkgs-stable,
      home-managerU,
      home-managerS,
      noctalia,
      agenix,
      nixvim,
      flatpaks,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      libU = nixpkgs-unstable.lib;
      libS = nixpkgs-stable.lib;

      overlays = [
        (final: prev: {
          future-cursors = prev.callPackage ./pkgs/future-cursor.nix { };
        })
      ];

      mkWorkstation =
        { deviceModule, hmImports }:
        libU.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = overlays; }
            deviceModule
            home-managerU.nixosModules.home-manager
            disko.nixosModules.disko
            flatpaks.nixosModules.default
            agenix.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupCommand = "rm";
                extraSpecialArgs = { inherit inputs; };
                sharedModules = [
                  (
                    { osConfig, ... }:
                    {
                      _module.args.hostName = osConfig.networking.hostName;
                    }
                  )
                ];
                users.gumbo = {
                  imports = hmImports;
                };
              };
            }
          ];
        };

      mkServer =
        { deviceModule, hmImports }:
        libS.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = overlays; }
            deviceModule
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./modules/baseline.server.nix
            ./modules/ssh.nix
            home-managerS.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupCommand = "rm";
                extraSpecialArgs = { inherit inputs; };
                sharedModules = [
                  (
                    { osConfig, ... }:
                    {
                      _module.args.hostName = osConfig.networking.hostName;
                    }
                  )
                ];
                users.gumbo = {
                  imports = hmImports;
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        erebos = mkWorkstation {
          deviceModule = ./devices/desktop/erebos/default.nix;
          hmImports = [
            ./home/common.nix
            ./home/zsh.nix
            ./home/kde.nix
          ];
        };

        prometheus = mkWorkstation {
          deviceModule = ./devices/laptop/prometheus/default.nix;
          hmImports = [
            ./home/common.nix
            ./home/zsh.nix
            ./home/niri.nix
          ];
        };

        null = mkWorkstation {
          deviceModule = ./devices/desktop/null/default.nix;
          hmImports = [
            ./home/common.nix
            ./home/zsh.nix
            ./home/kde.nix
          ];
        };

        console = mkWorkstation {
          deviceModule = ./devices/desktop/console/default.nix;
          hmImports = [
            ./home/common.nix
            ./home/zsh.nix
            ./home/kde.nix
          ];
        };

       # void = mkServer {
       #   deviceModule = ./devices/server/legacy/void/default.nix;
       #   hmImports = [
       #     ./home/server.nix
       #     ./home/zsh.nix
       #   ];
       # };
       # v-gaia-main = mkServer {
       #   deviceModule = ./devices/server/legacy/v-gaia-main/default.nix;
       #   hmImports = [
       #     ./home/server.nix
       #     ./home/zsh.nix
       #   ];
       # };
       # zeus = mkServer {
       #   deviceModule = ./devices/server/legacy/zeus/default.nix;
       #   hmImports = [
       #     ./home/server.nix
       #     ./home/zsh.nix
       #   ];
       # };
	      seed = mkWorkstation {
          deviceModule = ./devices/server/seed/default.nix;
          hmImports = [
            ./home/common.nix
            ./home/zsh.nix
            ./home/kde.nix
            ./home/rdp.nix
          ];
        };
        srv-n1 = mkServer {
          deviceModule = ./devices/server/srv-n1/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
        secret-mgmt = mkServer {
          deviceModule = ./devices/server/secret-mgmt/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
        k3s-a1 = mkServer {
          deviceModule = ./devices/server/k3s/k3s-a1/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
        k3s-a2 = mkServer {
          deviceModule = ./devices/server/k3s/k3s-a2/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
        k3s-a3 = mkServer {
          deviceModule = ./devices/server/k3s/k3s-a3/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
        k3s-a4 = mkServer {
          deviceModule = ./devices/server/k3s/k3s-a4/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
        k3s-s1 = mkServer {
          deviceModule = ./devices/server/k3s/k3s-s1/default.nix;
          hmImports = [
            ./home/server.nix
            ./home/zsh.nix
          ];
        };
      };
    };
}
