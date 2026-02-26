#!/bin/bash
# Bootstrap Nix environment context for AI agents
# Agent-agnostic: generates markdown context files that any agent can consume

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR=~/.local/bin
RUNBOOKS_DIR=~/.local/share/runbooks
CONTEXT_FILE=~/.nix-environment-context.md

# Install the context generation script
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/update-nix-context.sh" "$BIN_DIR/update-nix-context.sh"
chmod +x "$BIN_DIR/update-nix-context.sh"

# Create runbooks directory
mkdir -p "$RUNBOOKS_DIR"

# Generate initial context
"$BIN_DIR/update-nix-context.sh"

# Append runbooks to context file
if ls "$RUNBOOKS_DIR"/*.md &>/dev/null; then
  echo "" >> "$CONTEXT_FILE"
  echo "## Runbooks" >> "$CONTEXT_FILE"
  for f in "$RUNBOOKS_DIR"/*.md; do
    echo "### $(basename "$f" .md)" >> "$CONTEXT_FILE"
    cat "$f" >> "$CONTEXT_FILE"
    echo "" >> "$CONTEXT_FILE"
  done
fi

cat << 'EOF'

✅ Setup complete!

Generated: ~/.nix-environment-context.md
Script:    ~/.local/bin/update-nix-context.sh
Runbooks:  ~/.local/share/runbooks/

To wire this into your AI agent, configure it to read
~/.nix-environment-context.md as context on startup.

Examples:
  Kiro CLI  — add an agentSpawn hook to your agent JSON:
              "hooks": { "agentSpawn": [{ "command": "cat ~/.nix-environment-context.md" }] }
  Cursor    — add to .cursorrules or context files
  Copilot   — add to .github/copilot-instructions.md
  Claude    — include via CLAUDE.md or project context

Run `update-nix-context.sh` after `reload` to keep context fresh.
EOF
