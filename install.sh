#!/usr/bin/env bash
# install.sh - Install the strudel-music skill into a supported agent.
#
# Supported agents: cursor, claude, hermes, windsurf, opencode, xcode.
# Scopes:           global (~/.{agent}/) or project (./.{agent}/).
# Modes:            symlink (default, edits propagate) or copy (snapshot).
#
# Run with no arguments to enter the interactive prompt.
# Run with --help for the full usage.

set -euo pipefail

# -- Configuration ---------------------------------------------------------

# Absolute path to this script's directory (the skill source root).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="strudel-music"

# Agent registry: "name|global_parent|project_relative_parent".
# - global_parent:     absolute path checked for existence to "detect" the
#                      agent (e.g. ~/.cursor/skills/). Already expands $HOME
#                      at load time.
# - project_relative:  path used for the project scope, relative to the
#                      current working directory (e.g. .claude/skills/).
# The skill lands at <parent>/<SKILL_NAME>/ for both scopes.
AGENT_REGISTRY=(
  "cursor|${HOME}/.cursor/skills|.cursor/skills"
  "claude|${HOME}/.claude/skills|.claude/skills"
  "hermes|${HOME}/.hermes|.hermes"
  "windsurf|${HOME}/.windsurf|.windsurf"
  "opencode|${HOME}/.opencode|.opencode"
  "xcode|${HOME}/.xcode|.xcode"
)

# Required files in the skill source. Aborts install if any are missing.
REQUIRED_FILES=(SKILL.md reference.md genres.md examples.md)

# Files/dirs to exclude when copying the skill into an agent's skills dir.
# The symlink mode needs no exclusion (it points at the source as-is).
COPY_EXCLUDES=(.git node_modules .humanize docs)

# -- Helpers ---------------------------------------------------------------

print_usage() {
  cat <<'EOF'
Usage: bash install.sh [options]

Options:
  --agent <name>    Install for a specific agent: cursor, claude, hermes,
                    windsurf, opencode, or xcode.
  --all             Install for every detected agent.
  --scope <scope>   Install scope: global (~/.{agent}/) or project
                    (./.{agent}/). Default: global.
  --mode <mode>     Install mode: symlink (default) or copy.
  --dry-run         Print the plan but do not write anything.
  --list            List the agents detected on this system and exit.
  -h, --help        Show this help and exit.

If no agent option is given, the script prompts interactively.
EOF
}

die() {
  echo "install.sh: $*" >&2
  exit 1
}

agent_index() {
  local name="$1"
  local i
  for i in "${!AGENT_REGISTRY[@]}"; do
    local entry="${AGENT_REGISTRY[$i]}"
    if [ "${entry%%|*}" = "$name" ]; then
      echo "$i"
      return 0
    fi
  done
  return 1
}

detected_agents() {
  local entry name rest global_parent
  for entry in "${AGENT_REGISTRY[@]}"; do
    name="${entry%%|*}"
    rest="${entry#*|}"
    global_parent="${rest%%|*}"
    if [ -d "$global_parent" ]; then
      printf '%s\n' "$name"
    fi
  done
}

# -- Argument parsing ------------------------------------------------------

AGENT_NAME=""
INSTALL_ALL=false
SCOPE=""
MODE=""
DRY_RUN=false
LIST_ONLY=false

while [ $# -gt 0 ]; do
  case "$1" in
    --agent)
      [ $# -ge 2 ] || die "--agent requires a value"
      AGENT_NAME="$2"
      shift 2
      ;;
    --agent=*)
      AGENT_NAME="${1#*=}"
      shift
      ;;
    --all)
      INSTALL_ALL=true
      shift
      ;;
    --scope)
      [ $# -ge 2 ] || die "--scope requires a value (global|project)"
      SCOPE="$2"
      shift 2
      ;;
    --scope=*)
      SCOPE="${1#*=}"
      shift
      ;;
    --mode)
      [ $# -ge 2 ] || die "--mode requires a value (symlink|copy)"
      MODE="$2"
      shift 2
      ;;
    --mode=*)
      MODE="${1#*=}"
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      die "unexpected positional argument: $1 (try --help)"
      ;;
  esac
done

# -- Sanity checks (before any prompt or write) ----------------------------

# Abort if the source skill directory is incomplete.
for f in "${REQUIRED_FILES[@]}"; do
  if [ ! -e "${SCRIPT_DIR}/$f" ]; then
    die "source skill directory '${SCRIPT_DIR}' is missing required file '$f'"
  fi
done

# Reject contradictory argument combinations (exit non-zero per AC-11).
if [ -n "$AGENT_NAME" ] && $INSTALL_ALL; then
  die "--agent and --all are mutually exclusive"
fi
case "${SCOPE:-}" in
  ""|global|project) : ;;
  *) die "--scope must be 'global' or 'project' (got '$SCOPE')" ;;
esac
case "${MODE:-}" in
  ""|symlink|copy) : ;;
  *) die "--mode must be 'symlink' or 'copy' (got '$MODE')" ;;
esac
if [ -n "$AGENT_NAME" ]; then
  if ! agent_index "$AGENT_NAME" >/dev/null 2>&1; then
    die "unknown agent '$AGENT_NAME'. Valid: cursor, claude, hermes, windsurf, opencode, xcode"
  fi
fi

# -- --list short-circuit --------------------------------------------------

if $LIST_ONLY; then
  echo "Detected agents on this system:"
  local_count=0
  while IFS= read -r a; do
    if [ -n "$a" ]; then
      echo "  - $a"
      local_count=$((local_count + 1))
    fi
  done < <(detected_agents)
  if [ "$local_count" -eq 0 ]; then
    echo "  (none - none of the supported agents appear to be installed)"
  fi
  exit 0
fi

# -- Defaults for SCOPE and MODE -------------------------------------------

if [ -z "$SCOPE" ]; then
  SCOPE="global"
fi
if [ -z "$MODE" ]; then
  MODE="symlink"
fi

# -- Interactive prompts (only when not running non-interactively) ---------

# Read input from /dev/tty so the prompts work even when stdin is piped.
prompt_choice() {
  local var_name="$1"
  local prompt_text="$2"
  shift 2
  local options=("$@")
  local input_src="/dev/tty"
  echo "$prompt_text" >&2
  local i=1
  local opt
  for opt in "${options[@]}"; do
    echo "  $i) $opt" >&2
    i=$((i + 1))
  done
  local choice
  while true; do
    if [ -r "$input_src" ]; then
      read -r -p "Enter choice [1-${#options[@]}]: " choice < "$input_src" || choice=""
    else
      echo "Non-interactive shell detected; defaulting to option 1." >&2
      choice=1
    fi
    if [ -z "$choice" ]; then
      choice=1
    fi
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
      eval "$var_name=\"${options[$((choice - 1))]}\""
      return 0
    fi
    echo "Invalid choice. Please enter 1-${#options[@]}." >&2
  done
}

# Need an agent?
if [ -z "$AGENT_NAME" ] && ! $INSTALL_ALL; then
  mapfile -t detected < <(detected_agents)
  if [ "${#detected[@]}" -eq 0 ]; then
    die "no supported agents detected on this system. Install one of: cursor, claude, hermes, windsurf, opencode, xcode"
  fi
  local options=("${detected[@]}" "all")
  prompt_choice AGENT_NAME "Select target agent:" "${options[@]}"
  if [ "$AGENT_NAME" = "all" ]; then
    INSTALL_ALL=true
  fi
fi

# -- Build the list of agents to install -----------------------------------

targets=()
if $INSTALL_ALL; then
  while IFS= read -r a; do
    [ -n "$a" ] && targets+=("$a")
  done < <(detected_agents)
  if [ "${#targets[@]}" -eq 0 ]; then
    die "--all requested, but no supported agents are detected on this system"
  fi
else
  targets=("$AGENT_NAME")
fi

# -- Pre-install summary ---------------------------------------------------

echo "strudel-music installer"
echo "  source:  $SCRIPT_DIR"
echo "  scope:   $SCOPE"
echo "  mode:    $MODE"
if $DRY_RUN; then
  echo "  dry-run: yes (no files will be written)"
fi
echo "  targets:"
for agent in "${targets[@]}"; do
  echo "    - $agent"
done
echo

# -- Per-agent install -----------------------------------------------------

install_for_agent() {
  local agent="$1"
  local idx
  idx="$(agent_index "$agent")" || die "internal error: unknown agent '$agent'"
  local entry="${AGENT_REGISTRY[$idx]}"
  local _name _global _project
  IFS='|' read -r _name _global _project <<< "$entry"

  local parent
  if [ "$SCOPE" = "global" ]; then
    parent="$_global"
  else
    parent="$(pwd)/${_project}"
  fi

  # Ensure the parent directory exists (create it if missing).
  if [ ! -d "$parent" ]; then
    if $DRY_RUN; then
      echo "  [dry-run] would create parent: $parent"
    else
      mkdir -p "$parent"
    fi
  fi

  local target="${parent%/}/${SKILL_NAME}"

  # If the target is already a symlink that points at our source, we're done.
  if [ -L "$target" ] && [ "$(readlink "$target" 2>/dev/null || true)" = "$SCRIPT_DIR" ]; then
    echo "  already linked: $target -> $SCRIPT_DIR"
    return 0
  fi

  # If the target exists and is not our symlink, replace it.
  if [ -e "$target" ] || [ -L "$target" ]; then
    if $DRY_RUN; then
      echo "  [dry-run] would remove existing: $target"
    else
      rm -rf "$target"
    fi
  fi

  if $DRY_RUN; then
    case "$MODE" in
      symlink) echo "  [dry-run] would symlink: $target -> $SCRIPT_DIR" ;;
      copy)    echo "  [dry-run] would copy:    $target <- $SCRIPT_DIR" ;;
    esac
    return 0
  fi

  case "$MODE" in
    symlink)
      ln -s "$SCRIPT_DIR" "$target"
      echo "  symlinked: $target -> $SCRIPT_DIR"
      ;;
    copy)
      # Use cp -R for portability, then strip excluded paths.
      cp -R "$SCRIPT_DIR" "$target"
      local ex
      for ex in "${COPY_EXCLUDES[@]}"; do
        if [ -e "$target/$ex" ]; then
          rm -rf "$target/$ex"
        fi
      done
      echo "  copied: $target"
      ;;
  esac
}

for agent in "${targets[@]}"; do
  echo "[$agent]"
  install_for_agent "$agent"
done

# -- Post-install summary --------------------------------------------------

echo
echo "Done."
echo
echo "Summary:"
echo "  source:  $SCRIPT_DIR"
echo "  scope:   $SCOPE"
echo "  mode:    $MODE"
echo "  agents:  ${targets[*]}"
if $DRY_RUN; then
  echo "  (dry-run only - nothing was written)"
fi
echo
echo "Next steps:"
echo "  1. Run 'bash scripts/init.sh' to set up the local player at ~/strudel-music/."
echo "  2. Open http://localhost:5173/ in a browser."
echo "  3. Click the play button inside the strudel.cc iframe once (browser autoplay policy)."
echo "  4. The agent will edit 'templates/src/pattern.js' in response to your music requests."
