#!/usr/bin/env bash
# harness/antigravity/scripts/validate.sh
# Automated validation for ruby-dev Antigravity port.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== 1. Validating Antigravity plugin manifest ==="
if ! command -v agy &>/dev/null; then
  echo "ERROR: 'agy' command not found in PATH." >&2
  exit 1
fi

agy plugin validate "${HARNESS_DIR}"
echo "✔ agy plugin validate passed."

echo ""
echo "=== 2. Checking for untranslated Claude Code coupling tokens ==="
FORBIDDEN_TOKENS=(
  '\${CLAUDE_PLUGIN_ROOT}'
  'claude --agent'
  'Agent('
)

FAIL_TOKENS=0
for token in "${FORBIDDEN_TOKENS[@]}"; do
  # Search inside HARNESS_DIR, excluding git metadata and scripts directory if needed
  MATCHES=$(grep -rnE "${token}" "${HARNESS_DIR}" --exclude="validate.sh" 2>/dev/null || true)
  if [[ -n "${MATCHES}" ]]; then
    echo "ERROR: Found forbidden token '${token}' in harness/antigravity/:" >&2
    echo "${MATCHES}" >&2
    FAIL_TOKENS=1
  fi
done

if [[ "${FAIL_TOKENS}" -ne 0 ]]; then
  echo "Validation failed: untranslated Claude tokens found." >&2
  exit 1
fi
echo "✔ 0 untranslated Claude Code coupling tokens found."

echo ""
echo "=== 3. Validating required files and link paths ==="
REQUIRED_FILES=(
  "${HARNESS_DIR}/plugin.json"
  "${HARNESS_DIR}/rules/AGENTS.md"
  "${HARNESS_DIR}/agents/rubyist.md"
  "${HARNESS_DIR}/agents/specifier.md"
  "${HARNESS_DIR}/agents/implementer.md"
  "${HARNESS_DIR}/agents/cleaner.md"
  "${HARNESS_DIR}/agents/hardener.md"
  "${HARNESS_DIR}/agents/verifier.md"
  "${HARNESS_DIR}/tasks/gate-check.md"
  "${HARNESS_DIR}/tasks/step-1-survey-plan.md"
  "${HARNESS_DIR}/tasks/step-2-dispatch-reconcile.md"
  "${HARNESS_DIR}/tasks/step-3-gate-synthesize.md"
  "${HARNESS_DIR}/references/quality-gates.md"
  "${HARNESS_DIR}/references/subagent-mandates.md"
  "${HARNESS_DIR}/references/dry-rb-patterns.md"
  "${HARNESS_DIR}/references/logging-patterns.md"
  "${HARNESS_DIR}/references/environment-variables.md"
  "${HARNESS_DIR}/references/ood-principles.md"
  "${HARNESS_DIR}/references/rubysmith-scaffolding.md"
  "${HARNESS_DIR}/references/pry-console.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "ERROR: Required file missing: ${file}" >&2
    exit 1
  fi
done

# Check that relative links in agents/*.md resolve
for agent in "${HARNESS_DIR}/agents"/*.md; do
  AGENT_DIR="$(dirname "${agent}")"
  # Extract markdown links and path mentions matching ../skills/ or ../references/
  LINKS=$(grep -oE '\.\./(skills|references)/[^) `"]+' "${agent}" || true)
  for link in ${LINKS}; do
    TARGET="${AGENT_DIR}/${link}"
    if [[ ! -e "${TARGET}" ]]; then
      echo "ERROR: In ${agent}, broken link: ${link} -> ${TARGET}" >&2
      exit 1
    fi
  done
done

# Check that relative links in skills/role-*/SKILL.md resolve
for role in "${HARNESS_DIR}/skills"/role-*/SKILL.md; do
  ROLE_DIR="$(dirname "${role}")"
  LINKS=$(grep -oE '\.\./[^) `"]+' "${role}" || true)
  for link in ${LINKS}; do
    # Strip any trailing punctuation
    CLEAN_LINK=$(echo "${link}" | sed 's/[:;,.]*$//')
    TARGET="${ROLE_DIR}/${CLEAN_LINK}"
    if [[ ! -e "${TARGET}" ]]; then
      echo "ERROR: In ${role}, broken link: ${CLEAN_LINK} -> ${TARGET}" >&2
      exit 1
    fi
  done
done

# Check that relative links in tasks/*.md resolve
for task in "${HARNESS_DIR}/tasks"/*.md; do
  TASK_DIR="$(dirname "${task}")"
  LINKS=$(grep -oE '\.\./(references|tasks)/[^) `"]+' "${task}" || true)
  for link in ${LINKS}; do
    CLEAN_LINK=$(echo "${link}" | sed 's/[:;,.]*$//')
    TARGET="${TASK_DIR}/${CLEAN_LINK}"
    if [[ ! -e "${TARGET}" ]]; then
      echo "ERROR: In ${task}, broken link: ${CLEAN_LINK} -> ${TARGET}" >&2
      exit 1
    fi
  done
done

echo "✔ All required files and internal links verified successfully."
echo ""
echo "=== All validation checks passed successfully! ==="
