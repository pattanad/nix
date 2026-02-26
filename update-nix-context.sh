#!/bin/bash
# Regenerate Nix environment context for Kiro CLI agents

FLAKE=~/.config/nixpkgs/flake.nix
OUT=~/.nix-environment-context.md

cat > "$OUT" << 'EOF'
# Nix Environment Context

## System
EOF

echo "- Platform: $(nix eval --raw nixpkgs#system 2>/dev/null || echo 'aarch64-darwin')" >> "$OUT"
echo "- Nix: $(nix --version | cut -d' ' -f3)" >> "$OUT"
echo "- Home Manager: $(home-manager --version 2>/dev/null || echo 'unknown')" >> "$OUT"
echo "- Config: \`$FLAKE\`" >> "$OUT"

cat >> "$OUT" << 'EOF'

## Shell & Tools
EOF

# Extract key info from flake
grep -A2 'programs.zsh' "$FLAKE" | head -1 | grep -q 'enable = true' && echo "- Shell: zsh with starship, zoxide, fzf" >> "$OUT"
grep -q 'neovim' "$FLAKE" && echo "- Editor: neovim" >> "$OUT"
grep -q 'wezterm' "$FLAKE" && echo "- Terminal: wezterm, tmux" >> "$OUT"
echo "- Modern CLI: eza, bat, ripgrep, fd, delta" >> "$OUT"

cat >> "$OUT" << 'EOF'

## Key Aliases
EOF

# Extract useful aliases
grep -E '^\s+"(reload|edit-config|bb|k)\s*=' "$FLAKE" | sed 's/.*"\([^"]*\)"\s*=\s*"\([^"]*\)".*/- `\1` - \2/' >> "$OUT"

cat >> "$OUT" << 'EOF'

## Development
EOF

# Extract packages
grep -q 'nodejs' "$FLAKE" && echo "- Node.js, Python, Bun, TypeScript" >> "$OUT"
echo "- LSPs: typescript-language-server, pyright, clangd, jdtls, kotlin-language-server" >> "$OUT"
echo "- Git with delta integration" >> "$OUT"

cat >> "$OUT" << 'EOF'

## Brazil (Amazon)
- `bb`, `bba`, `bbr`, `bball` - build commands
- `bws`, `bwsuse`, `bwscreate` - workspace commands

## Updating This Environment
Run: `~/.local/bin/update-nix-context.sh`
EOF

echo "Updated: $OUT"
