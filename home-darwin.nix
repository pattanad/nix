{ config, pkgs, ... }: {
  imports = [ ./home-shared.nix ];

  home.packages = with pkgs; [ wezterm imagemagick clang clang-tools ];

  home.shellAliases = {
    reload = "sudo darwin-rebuild switch --flake ~/.config/nixpkgs && ~/.local/bin/update-nix-context.sh";
  };

  programs.zsh.initContent = ''
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
      local act = wezterm.action

      -- appearance
      config.color_scheme = 'Catppuccin Mocha'
      -- performance
      config.scrollback_lines = 500000
      config.max_fps = 120
      config.animation_fps = 1

      -- tab bar
      config.use_fancy_tab_bar = false
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = false
      config.tab_max_width = 32
      config.show_new_tab_button_in_tab_bar = false

      -- window
      config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
      config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.7 }

      -- hyperlinks
      config.hyperlink_rules = wezterm.default_hyperlink_rules()

      -- theme switching
      local function set_scheme(scheme)
        return function(window, pane)
          window:set_config_overrides({ color_scheme = scheme })
        end
      end
      wezterm.on('set-kanagawa', set_scheme('Kanagawa (Gogh)'))
      wezterm.on('set-catppuccin', set_scheme('Catppuccin Mocha'))
      wezterm.on('set-solarized', set_scheme('Solarized Dark'))

      -- status bar: workspace | cwd | date
      wezterm.on('update-status', function(window, pane)
        local ws = window:active_workspace()
        local cwd = ""
        local info = pane:get_current_working_dir()
        if info then
          cwd = info.file_path or ""
          cwd = cwd:gsub('^/Users/pattanad', '~')
        end
        local time = wezterm.strftime '%H:%M'

        local left = {
          { Background = { Color = '#89b4fa' } }, { Foreground = { Color = '#1e1e2e' } },
          { Text = ' ' .. ws .. ' ' },
          { Background = { Color = '#313244' } }, { Foreground = { Color = '#cdd6f4' } },
          { Text = ' ' .. cwd .. ' ' },
        }
        local right = {
          { Background = { Color = '#313244' } }, { Foreground = { Color = '#a6adc8' } },
          { Text = ' ' .. time .. ' ' },
        }
        window:set_left_status(wezterm.format(left))
        window:set_right_status(wezterm.format(right))
      end)

      -- tab title: index + process name
      wezterm.on('format-tab-title', function(tab)
        local title = tab.active_pane.title
        if title and #title > 24 then title = title:sub(1, 24) .. '…' end
        local idx = tab.tab_index + 1
        return ' ' .. idx .. ': ' .. (title or 'zsh') .. ' '
      end)

      -- workspace definitions
      local workspaces = {
        { key = '1', mods = 'CMD|CTRL', name = 'encore', cwd = '/Volumes/workplace/encore-4/src/FireTVProjectEncore', scheme = 'set-kanagawa' },
        { key = '2', mods = 'CMD|CTRL', name = 'default', cwd = wezterm.home_dir, scheme = 'set-catppuccin' },
        { key = '3', mods = 'CMD|CTRL', name = 'scratch', cwd = wezterm.home_dir, scheme = 'set-solarized' },
      }

      config.keys = {
        -- launcher / workspace switcher
        { key = ' ', mods = 'CMD|SHIFT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES|TABS|LAUNCH_MENU_ITEMS' } },

        -- quick select: highlights URLs, paths, hashes, IPs — press label to copy
        { key = 'y', mods = 'CMD|SHIFT', action = act.QuickSelect },

        -- copy mode (vim-style scrollback navigation)
        { key = 'x', mods = 'CMD|SHIFT', action = act.ActivateCopyMode },

        -- splits
        { key = '|', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '_', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

        -- pane navigation
        { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
        { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
        { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
        { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },

        -- pane resizing (enter resize mode)
        { key = 'r', mods = 'CMD|SHIFT', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

        -- search
        { key = 'f', mods = 'CMD', action = act.Multiple {
          act.CopyMode 'ClearPattern',
          act.Search 'CurrentSelectionOrEmptyString',
        }},
        { key = 'f', mods = 'CTRL|SHIFT', action = act.Multiple {
          act.CopyMode 'ClearPattern',
          act.Search 'CurrentSelectionOrEmptyString',
        }},
        { key = 'F', mods = 'CMD|SHIFT', action = act.Multiple {
          act.CopyMode 'ClearPattern',
          act.Search { CaseSensitiveString = "" },
        }},

        -- clear
        { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },

        -- close pane
        { key = 'w', mods = 'CMD|SHIFT', action = act.CloseCurrentPane { confirm = true } },

        -- rename workspace
        { key = 'R', mods = 'CTRL|SHIFT', action = act.PromptInputLine {
          description = 'Rename workspace:',
          action = wezterm.action_callback(function(window, pane, line)
            if line then window:perform_action(act.SwitchToWorkspace { name = line }, pane) end
          end),
        }},
      }

      -- add workspace keybindings
      for _, ws in ipairs(workspaces) do
        table.insert(config.keys, {
          key = ws.key, mods = ws.mods,
          action = act.Multiple {
            act.SwitchToWorkspace { name = ws.name, spawn = { cwd = ws.cwd } },
            act.EmitEvent(ws.scheme),
          },
        })
      end

      config.key_tables = {
        search_mode = {
          { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
          { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
          { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
          { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
          { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
          { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
          { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
          { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
          { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
          { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
        },

        copy_mode = {
          { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
          { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
          -- movement
          { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
          { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
          { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
          { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
          { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
          { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
          { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
          { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
          { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
          { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
          -- page movement
          { key = 'u', mods = 'CTRL', action = act.CopyMode 'PageUp' },
          { key = 'd', mods = 'CTRL', action = act.CopyMode 'PageDown' },
          -- selection
          { key = 'v', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Cell' } },
          { key = 'V', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
          { key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } },
          -- yank
          { key = 'y', mods = 'NONE', action = act.Multiple {
            act.CopyTo 'ClipboardAndPrimarySelection',
            act.CopyMode 'Close',
          }},
          -- search from copy mode
          { key = '/', mods = 'NONE', action = act.Search 'CurrentSelectionOrEmptyString' },
        },

        resize_pane = {
          { key = 'h', mods = 'NONE', action = act.AdjustPaneSize { 'Left', 2 } },
          { key = 'j', mods = 'NONE', action = act.AdjustPaneSize { 'Down', 2 } },
          { key = 'k', mods = 'NONE', action = act.AdjustPaneSize { 'Up', 2 } },
          { key = 'l', mods = 'NONE', action = act.AdjustPaneSize { 'Right', 2 } },
          { key = 'Escape', mods = 'NONE', action = 'PopKeyTable' },
          { key = 'Enter', mods = 'NONE', action = 'PopKeyTable' },
        },
      }

      -- quick select patterns (added to defaults)
      config.quick_select_patterns = {
        '[a-f0-9]{6,40}',          -- git hashes
        'CR-[0-9]+',               -- code reviews
        '[A-Z]+-[0-9]+',           -- JIRA tickets
        '/[\\w./:-]+',             -- file paths
      }

      return config
    '';
  };

  home.activation.kiroSkillsAgent = config.lib.dag.entryAfter [ "kiroConfig" ] ''
    cat > ~/.kiro/agents/skills.json << 'EOF'
{
  "name": "skills",
  "description": "Load and execute agent skills on demand using SkillsTool.",
  "prompt": "You have access to SkillsTool. When asked to load a skill, invoke SkillsTool with the skill name immediately. Do not search the filesystem.",
  "tools": ["@builtin", "@builder-mcp/SkillsTool"],
  "allowedTools": ["@builder-mcp/SkillsTool"],
  "mcpServers": {
    "builder-mcp": {
      "command": "builder-mcp",
      "args": ["--include-tools", "SkillsTool", "--skill-paths", "/Users/pattanad/.aim/skills/FlaxAgentSkills,/Users/pattanad/.aim/skills/local,/Users/pattanad/.aim/skills/AmazonBuilderCoreAISkillSet", "--skill-name-filter", "*"]
    }
  },
  "useLegacyMcpJson": false
}
EOF
    chmod 644 ~/.kiro/agents/skills.json
  '';

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
