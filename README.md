# Nix Configuration

Declarative system and user environment configuration using Nix Flakes, nix-darwin, and Home Manager.

## Overview

This repo manages:
- **macOS (Darwin)**: Full system config via nix-darwin + Home Manager
- **Linux**: User environment via standalone Home Manager

## Structure

```
├── flake.nix         # Entry point - defines inputs and system configurations
├── home.nix          # macOS home entry (imports home-darwin.nix)
├── home-darwin.nix   # macOS-specific: wezterm, brew paths, reload alias
├── home-linux.nix    # Linux-specific: standalone home-manager config
└── home-shared.nix   # Shared: packages, shell config, git, tmux, aliases
```

## Prerequisites

### macOS
```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# Enable flakes (add to ~/.config/nix/nix.conf)
experimental-features = nix-command flakes
```

### Linux
```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh --daemon

# Install Home Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

## Usage

### Initial Setup (macOS)
```bash
# First time - bootstrap nix-darwin
nix run nix-darwin -- switch --flake ~/.config/nixpkgs
```

### Initial Setup (Linux)
```bash
nix run home-manager -- switch --flake ~/.config/nixpkgs#pattanad@linux
```

### Applying Changes

After editing any `.nix` file:

```bash
# macOS
reload   # alias for: sudo darwin-rebuild switch --flake ~/.config/nixpkgs

# Linux
reload   # alias for: home-manager switch --flake ~/.config/nixpkgs#pattanad@linux
```

### Updating Inputs
```bash
nix flake update              # Update all inputs
nix flake lock --update-input nixpkgs  # Update specific input
```

## What's Included

### Packages
- **Core**: coreutils, neovim, tmux, direnv
- **Modern CLI**: eza, bat, ripgrep, fd, fzf, zoxide, jq, delta
- **Dev**: nodejs, python3, typescript, clang, cmake, ninja, bun, uv
- **LSPs**: typescript-language-server, pyright, clang-tools, jdt-language-server, kotlin-language-server
- **Git**: gh, lazygit

### Shell (zsh)
- Autosuggestions, syntax highlighting, history substring search
- Starship prompt, fzf integration, zoxide (smart cd)
- Extensive aliases for git, Brazil, ripgrep, fd

### Key Aliases

| Alias | Command |
|-------|---------|
| `ll`, `la`, `lt` | eza variants |
| `gs`, `ga`, `gc`, `gp` | git shortcuts |
| `bb`, `bbr`, `bball` | Brazil build |
| `bws`, `bwsuse` | Brazil workspace |
| `cat`, `grep`, `find` | bat, rg, fd |
| `reload` | Rebuild nix config |
| `edit-config` | Edit flake.nix in nvim |

### Tmux
- Prefix: `Ctrl-a`
- Vi keybindings
- `|` / `-` for splits
- `h/j/k/l` for pane navigation

### WezTerm (macOS)
- Catppuccin Mocha theme
- `Cmd+Ctrl+1/2/3` - workspace presets with different themes
- `Ctrl+Shift+|/_` - splits
- `Cmd+f` - search

## Customization

### Adding Packages
Edit `home-shared.nix`:
```nix
home.packages = with pkgs; [
  # add packages here
];
```

### Adding Aliases
Edit `home-shared.nix`:
```nix
home.shellAliases = {
  myalias = "my command";
};
```

### Platform-Specific Changes
- macOS only: edit `home-darwin.nix`
- Linux only: edit `home-linux.nix`

## Troubleshooting

```bash
# Check flake syntax
nix flake check

# Build without switching
nix build .#darwinConfigurations.842f57a680ea.system  # macOS
nix build .#homeConfigurations.pattanad@linux.activationPackage  # Linux

# Garbage collect old generations
nix-collect-garbage -d
```

## Notes

- The Darwin config is tied to hostname `842f57a680ea` - update in `flake.nix` if your hostname differs
- macOS config sources Homebrew and mise; install separately if needed
- Run `~/.local/bin/update-nix-context.sh` after reload to update shell context
