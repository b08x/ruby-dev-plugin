#!/usr/bin/env bash
# Start the rubydex MCP server (`rdx mcp`) for the current project.
#
# Uses the project bundle when Gemfile.lock resolves rubydex, so the server
# indexes the project's own gem versions. Falls back to a globally installed
# `rdx`. Exits non-zero, with the reason on stderr, when the project has no
# Gemfile (rubydex 0.4.2 indexing raises Bundler::GemfileNotFound) or no rdx.
set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$root"

if [[ ! -f Gemfile ]]; then
  echo "rubydex-mcp: no Gemfile in ${root}; rubydex indexes Ruby projects only." >&2
  exit 1
fi

if [[ -f Gemfile.lock ]] && grep -qE '^    rubydex ' Gemfile.lock; then
  exec bundle exec rdx mcp "$root"
elif command -v rdx >/dev/null 2>&1; then
  exec rdx mcp "$root"
fi

echo "rubydex-mcp: rdx not found in the project bundle or on PATH." \
  "Run the orchestrator's analysis-gems step, or: gem install rubydex" >&2
exit 1
