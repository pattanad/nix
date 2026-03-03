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
      "args": ["--include-tools", "SkillsTool", "--skill-paths", "/home/pattanad/.aim/skills/FlaxAgentSkills", "--skill-name-filter", "*"]
    }
  },
  "useLegacyMcpJson": false
}
EOF
    chmod 644 ~/.kiro/agents/skills.json
  '';
}
