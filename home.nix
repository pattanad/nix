{ config, pkgs, ... }: {
  programs.home-manager.enable = true;
  
  home.stateVersion = "24.11";

  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "..3" = "cd ../../..";
    ll = "eza -l";
    la = "eza -la";
    lt = "eza --tree";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log --oneline";
    gd = "git diff";
    gco = "git checkout";
    gb = "git branch";
    gpr = "git pull --rebase";
    gcp = "git cherry-pick";
    cat = "bat";
    grep = "rg";
    find = "fd";
    reload = "darwin-rebuild switch --flake ~/.config/nixpkgs && ~/.local/bin/update-nix-context.sh";
    edit-config = "nvim ~/.config/nixpkgs/flake.nix";
    k = "kiro-cli";
    bb = "brazil-build";
    bba = "brazil-build apollo-pkg";
    bre = "brazil-runtime-exec";
    brc = "brazil-recursive-cmd";
    bws = "brazil ws";
    bwsuse = "bws use --gitMode -p";
    bwscreate = "bws create -n";
    bbr = "brc brazil-build";
    bball = "brc --allPackages";
    bbb = "brc --allPackages brazil-build";
    bbra = "bbr apollo-pkg";
    bbca = "bb clean && bba";
    bbcr = "bb clean && bb release";
    bbcs = "bb clean && bb server";
    bbrb = "bws clean && brc --allPackages -- brazil-build";
    bbstart = "adb reverse tcp:8081 tcp:8081 && brazil-build-tool-exec npm-pretty-much start";
    vegalog = "vda shell journalctl -f --no-pager";
    vls = "vda shell vlcm list";
    vpls = "vda shell vpm list apps";
    vpminfo = "vda shell vpm info";
    dl = "adb shell vlcm launch-app";
    dt = "adb shell vlcm terminate-app --pkg-id";
    edabb = "eda build brazil-build";
  };

  home.packages = with pkgs; [
    coreutils ffmpeg wezterm neovim tmux direnv
    starship fzf eza bat ripgrep fd tree jq curl
    gh lazygit btop zoxide
    clang cmake ninja nodejs_20 yarn typescript python3 uv bun
    lua-language-server nodePackages.typescript-language-server pyright
    clang-tools jdt-language-server kotlin-language-server
  ];

  programs.git = {
    enable = true;
    userName = "Pavan Pattanada";
    userEmail = "pattand@amazon.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

  programs.delta = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    
    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };
    
    shellAliases = {
      rg = "rg --smart-case --follow --hidden";
      rgf = "rg --files-with-matches";
      rgi = "rg -i";
      rgcpp = "rg --type cpp";
      rgc = "rg --type c";
      rgrs = "rg --type rust";
      rgj = "rg --type java";
      rgjs = "rg --type js";
      rgkt = "rg --type kotlin";
      rgh = "rg --glob '*.h' --glob '*.hpp'";
      ff = "fd --type f --hidden --follow --exclude .git";
      ffd = "fd --type d --hidden --follow --exclude .git";
      ffcpp = "fd -e cpp -e cc -e cxx -e c -e h -e hpp";
      ffrs = "fd -e rs";
      ffj = "fd -e java";
      ffjs = "fd -e js -e ts -e jsx -e tsx";
      ffkt = "fd -e kt -e kts";
      search = "rg --files | fzf --preview 'bat --color=always {}'";
      searchcode = "rg --line-number --color=always --smart-case";
    };
    
    initExtra = ''
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
      
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=header,grid --line-range :300 {}"'
      export FZF_CTRL_R_OPTS='--preview "echo {}" --preview-window down:3:hidden:wrap --bind "?:toggle-preview"'
      
      eval "$(fzf --zsh)"
      
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
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
      wezterm.on('set-dracula', set_scheme('Dracula'))
      wezterm.on('set-catppuccin', set_scheme('Catppuccin Mocha'))
      wezterm.on('set-solarized', set_scheme('Solarized Dark'))
      
      config.keys = {
        { key = ' ', mods = 'CMD|SHIFT', action = wezterm.action.ShowLauncher },
        { key = '1', mods = 'CMD|CTRL', action = wezterm.action.Multiple {
          wezterm.action.SpawnCommandInNewTab {
            args = { 'zsh', '-c', 'cd /Volumes/workplace/encore-4/src/FireTVProjectEncore && exec zsh' },
          },
          wezterm.action.EmitEvent 'set-dracula',
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

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    
    extraConfig = ''
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
      bind c new-window -c "#{pane_current_path}"
      set -g status-position bottom
      set -g status-bg colour234
      set -g status-fg colour137
      set -g status-left ""
      set -g status-right "#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S "
      set -g status-right-length 50
      set -g status-left-length 20
      setw -g window-status-current-format " #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F "
      setw -g window-status-format " #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F "
      set -g pane-border-style fg=colour238
      set -g pane-active-border-style fg=colour51
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
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
