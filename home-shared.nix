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
    edit-config = "nvim ~/.config/nixpkgs/flake.nix";
    k = "kiro-cli";
    # Brazil
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
    # Vega/ADB
    vegalog = "vda shell journalctl -f --no-pager";
    vls = "vda shell vlcm list";
    vpls = "vda shell vpm list apps";
    vpminfo = "vda shell vpm info";
    dl = "adb shell vlcm launch-app";
    dt = "adb shell vlcm terminate-app --pkg-id";
    edabb = "eda build brazil-build";
  };

  home.packages = with pkgs; [
    coreutils ffmpeg neovim tmux direnv
    starship fzf eza bat ripgrep fd tree jq curl
    gh lazygit btop zoxide
    clang cmake ninja nodejs_20 yarn typescript python3 uv bun
    lua-language-server nodePackages.typescript-language-server pyright
    clang-tools jdt-language-server kotlin-language-server
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Pavan Pattanada";
      user.email = "pattand@amazon.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

  programs.delta.enable = true;

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
}
