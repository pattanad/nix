{
  description = "Home Manager config (minimal)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations = {
        # Use your macOS username here (exact).
        pattanad = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ({ config, pkgs, ... }: {
              programs.home-manager.enable = true;
              
              # Required: specify the state version
              home.stateVersion = "24.05";
              
              # Set your username and home directory
              home.username = "pattanad";
              home.homeDirectory = "/Users/pattanad";

              # Example: install packages
              home.packages = [
                pkgs.neovim
                pkgs.tmux
                pkgs.git
                pkgs.direnv
              ];

              programs.direnv.enable = true;
            })
          ];
        };
      };
    };
}

