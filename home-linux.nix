{ config, pkgs, ... }: {
  imports = [ ./home-shared.nix ];

  home.username = "pattanad";
  home.homeDirectory = "/home/pattanad";

  home.shellAliases = {
    reload = "home-manager switch --flake ~/.config/nixpkgs#pattanad@linux";
  };

  programs.zsh.initContent = ''
    export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:$HOME/.toolbox/bin:/usr/bin:/usr/local/bin:$PATH
  '';
}
