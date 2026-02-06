{ config, pkgs, ... }: {
  imports = [ ./home-shared.nix ];

  home.username = "pattanad";
  home.homeDirectory = "/home/pattanad";

  home.shellAliases = {
    reload = "home-manager switch --flake ~/.config/nixpkgs#pattanad@linux";
  };

  programs.zsh.initExtra = ''
    export PATH=$HOME/.toolbox/bin:$PATH
  '';
}
