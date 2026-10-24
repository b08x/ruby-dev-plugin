#!/usr/bin/env bash
# harness/antigravity/scripts/install.sh
# Installer for the ruby-dev Antigravity plugin and rubyist orchestrator agent.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

INSTALL_MODE="global"
USE_SYMLINK=false
TARGET_DIR=""

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --global        Install user-globally into ~/.gemini/config/plugins/ruby-dev (default)
                  and ~/.gemini/agents/rubyist.md
  --local         Install project-locally into .agents/plugins/ruby-dev
                  (relative to current working directory)
  --target <path> Install to a specific custom plugin directory
  --symlink       Create symbolic links instead of copying files
  -h, --help      Show this help message
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      INSTALL_MODE="global"
      shift
      ;;
    --local)
      INSTALL_MODE="local"
      shift
      ;;
    --target)
      INSTALL_MODE="custom"
      TARGET_DIR="$2"
      shift 2
      ;;
    --symlink)
      USE_SYMLINK=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [[ "${INSTALL_MODE}" == "global" ]]; then
  DEST_PLUGIN_DIR="${HOME}/.gemini/config/plugins/ruby-dev"
elif [[ "${INSTALL_MODE}" == "local" ]]; then
  DEST_PLUGIN_DIR="$(pwd)/.agents/plugins/ruby-dev"
elif [[ "${INSTALL_MODE}" == "custom" ]]; then
  DEST_PLUGIN_DIR="${TARGET_DIR}"
fi

echo "Installing ruby-dev Antigravity plugin (${INSTALL_MODE} mode)..."
echo "Plugin destination: ${DEST_PLUGIN_DIR}"

mkdir -p "${DEST_PLUGIN_DIR}"

if [[ "${USE_SYMLINK}" == true ]]; then
  # Link individual components or harness directory
  for item in plugin.json agents skills references tasks rules; do
    rm -rf "${DEST_PLUGIN_DIR}/${item}"
    ln -s "${HARNESS_DIR}/${item}" "${DEST_PLUGIN_DIR}/${item}"
  done
  echo "✔ Symlinked plugin files to ${DEST_PLUGIN_DIR}"
else
  # Copy/rsync plugin contents
  if command -v rsync &>/dev/null; then
    rsync -a --delete \
      --exclude="scripts" \
      --exclude="README.md" \
      "${HARNESS_DIR}/" "${DEST_PLUGIN_DIR}/"
  else
    cp -r "${HARNESS_DIR}/plugin.json" "${DEST_PLUGIN_DIR}/"
    cp -r "${HARNESS_DIR}/agents" "${DEST_PLUGIN_DIR}/"
    cp -r "${HARNESS_DIR}/skills" "${DEST_PLUGIN_DIR}/"
    cp -r "${HARNESS_DIR}/references" "${DEST_PLUGIN_DIR}/"
    cp -r "${HARNESS_DIR}/tasks" "${DEST_PLUGIN_DIR}/"
    cp -r "${HARNESS_DIR}/rules" "${DEST_PLUGIN_DIR}/"
  fi
  echo "✔ Copied plugin files to ${DEST_PLUGIN_DIR}"
fi

# Always install orchestrator agent rubyist.md into ~/.gemini/agents/ for `agy --agent rubyist`
USER_AGENTS_DIR="${HOME}/.gemini/agents"
mkdir -p "${USER_AGENTS_DIR}"
RUBYIST_SRC="${HARNESS_DIR}/agents/rubyist.md"
RUBYIST_DEST="${USER_AGENTS_DIR}/rubyist.md"

if [[ "${USE_SYMLINK}" == true ]]; then
  ln -sf "${RUBYIST_SRC}" "${RUBYIST_DEST}"
  echo "✔ Symlinked rubyist orchestrator to ${RUBYIST_DEST}"
else
  cp "${RUBYIST_SRC}" "${RUBYIST_DEST}"
  echo "✔ Installed rubyist orchestrator to ${RUBYIST_DEST}"
fi

echo ""
echo "Installation complete!"
echo "- Verify plugin: agy plugin list"
echo "- Start orchestrator session: agy --agent rubyist"
