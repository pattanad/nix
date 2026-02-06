{
  description = "nix-darwin + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."842f57a680ea" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.hostPlatform = "aarch64-darwin";
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          programs.zsh.enable = true;
          system.stateVersion = 5;
        })
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          users.users.pattanad.home = "/Users/pattanad";
          home-manager.users.pattanad = import ./home.nix;
        }
      ];
    };

    homeConfigurations."pattanad@linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home-linux.nix ];
    };
  };
}
