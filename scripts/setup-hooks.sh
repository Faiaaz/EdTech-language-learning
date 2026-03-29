#!/bin/sh
# setup-hooks.sh: configure git to use the project's shared hooks directory.
#
# Run once after cloning:
#   sh scripts/setup-hooks.sh

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

HOOKS_DIR="$REPO_ROOT/.githooks"
if [ ! -d "$HOOKS_DIR" ]; then
  echo "Error: $HOOKS_DIR not found." >&2
  exit 1
fi

git config core.hooksPath "$HOOKS_DIR"
chmod +x "$HOOKS_DIR"/*

echo "Git hooks installed from $HOOKS_DIR"
echo "Run 'git pull' freely — branches will now auto-track their remote."
