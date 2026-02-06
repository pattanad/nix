{ config, pkgs, ... }: {
  imports = [ ./home-shared.nix ];

  home.packages = with pkgs; [ wezterm ];

  home.shellAliases = {
    reload = "sudo darwin-rebuild switch --flake ~/.config/nixpkgs && ~/.local/bin/update-nix-context.sh";
  };

  programs.zsh.initExtra = ''
    export PATH=$HOME/.toolbox/bin:$PATH
    source /Users/pattanad/.brazil_completion/zsh_completion 2>/dev/null || true
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    eval "$(mise activate zsh)" 2>/dev/null || true
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-25.jdk/Contents/Home"
    export PATH="/opt/homebrew/opt/node@18/bin:$PATH"
    export CPPFLAGS="-I$(brew --prefix krb5)/include"
    export LDFLAGS="-L$(brew --prefix krb5)/lib"
    export LIBRARY_PATH="/opt/homebrew/opt/libiconv/lib:$LIBRARY_PATH"
    ulimit -n 65536
  '';

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()
      config.color_scheme = 'Catppuccin Mocha'
      config.scrollback_lines = 500000
      config.max_fps = 120
      config.animation_fps = 1
      
      local function set_scheme(scheme)
        return function(window, pane)
          window:set_config_overrides({ color_scheme = scheme })
        end
      end
      wezterm.on('set-kanagawa', set_scheme('Kanagawa (Gogh)'))
      wezterm.on('set-catppuccin', set_scheme('Catppuccin Mocha'))
      wezterm.on('set-solarized', set_scheme('Solarized Dark'))
      
      config.keys = {
        { key = ' ', mods = 'CMD|SHIFT', action = wezterm.action.ShowLauncher },
        { key = '1', mods = 'CMD|CTRL', action = wezterm.action.Multiple {
          wezterm.action.SpawnCommandInNewTab {
            args = { 'zsh', '-c', 'cd /Volumes/workplace/encore-4/src/FireTVProjectEncore && exec zsh' },
          },
          wezterm.action.EmitEvent 'set-kanagawa',
        }},
        { key = '2', mods = 'CMD|CTRL', action = wezterm.action.Multiple {
          wezterm.action.SpawnCommandInNewTab { args = { 'zsh' } },
          wezterm.action.EmitEvent 'set-catppuccin',
        }},
        { key = '3', mods = 'CMD|CTRL', action = wezterm.action.Multiple {
          wezterm.action.SpawnCommandInNewTab { args = { 'zsh' } },
          wezterm.action.EmitEvent 'set-solarized',
        }},
        { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
        { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
        { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
        { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
        { key = 'f', mods = 'CMD', action = wezterm.action.Multiple {
          wezterm.action.CopyMode 'ClearPattern',
          wezterm.action.Search 'CurrentSelectionOrEmptyString',
        }},
        { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.Multiple {
          wezterm.action.CopyMode 'ClearPattern',
          wezterm.action.Search 'CurrentSelectionOrEmptyString',
        }},
        { key = 'F', mods = 'CMD|SHIFT', action = wezterm.action.Multiple {
          wezterm.action.CopyMode 'ClearPattern',
          wezterm.action.Search { CaseSensitiveString = "" },
        }},
        { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
      }
      
      config.key_tables = {
        search_mode = {
          { key = 'Enter', mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatch' },
          { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
          { key = 'n', mods = 'CTRL', action = wezterm.action.CopyMode 'NextMatch' },
          { key = 'p', mods = 'CTRL', action = wezterm.action.CopyMode 'PriorMatch' },
          { key = 'r', mods = 'CTRL', action = wezterm.action.CopyMode 'CycleMatchType' },
          { key = 'u', mods = 'CTRL', action = wezterm.action.CopyMode 'ClearPattern' },
          { key = 'PageUp', mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatchPage' },
          { key = 'PageDown', mods = 'NONE', action = wezterm.action.CopyMode 'NextMatchPage' },
          { key = 'UpArrow', mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatch' },
          { key = 'DownArrow', mods = 'NONE', action = wezterm.action.CopyMode 'NextMatch' },
        },
      }
      return config
    '';
  };

  home.activation.aliasApplications = ''
    echo "Linking applications..."
    if [ -d ~/.nix-profile/Applications ]; then
      for app in ~/.nix-profile/Applications/*.app; do
        if [ -d "$app" ]; then
          app_name=$(basename "$app")
          if [ ! -e "/Applications/$app_name" ]; then
            $DRY_RUN_CMD ln -sf "$app" "/Applications/$app_name"
          fi
        fi
      done
    fi
  '';
}
