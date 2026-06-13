#!/usr/bin/env bash
# scripts/init.sh - Initialize the strudel-music local player.
#
# What it does:
#   1. Verifies that `node` is installed and reports a version >= 18.
#   2. Copies ./templates/ to ${HOME}/strudel-music/ (warns and asks before
#      overwriting an existing installation).
#   3. Runs `npm install` inside that directory. Skipped if node_modules/
#      is already populated AND package.json is byte-identical to the
#      source (compared via sha256sum).
#   4. Optionally invokes scripts/download-samples.sh when --with-samples
#      is passed.
#   5. Starts the Vite dev server in the background on port 5173,
#      redirecting output to ${HOME}/strudel-music-dev.log and writing the
#      PID to ${HOME}/strudel-music-dev.pid. Re-running stops the previous
#      Vite process (if any) and starts a fresh one.
#
# Re-running is safe: it detects the existing installation, refreshes the
# templates in place, skips npm install when nothing changed, and restarts
# the dev server.

set -euo pipefail

# -- Configuration ---------------------------------------------------------

# Resolve the repo root and the locations of the inputs we need.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATES_DIR="${REPO_DIR}/templates"
DOWNLOAD_SAMPLES="${SCRIPT_DIR}/download-samples.sh"

# Defaults; can be overridden by --target.
TARGET_DIR="${HOME}/strudel-music"
LOG_FILE="${HOME}/strudel-music-dev.log"
PID_FILE="${HOME}/strudel-music-dev.pid"
PORT=5173

# -- Helpers ---------------------------------------------------------------

print_usage() {
  cat <<'EOF'
Usage: bash scripts/init.sh [options]

Options:
  --target <path>    Install the player into a different directory
                     (default: ~/strudel-music).
  --with-samples     Also run scripts/download-samples.sh after the
                     templates are copied. Requires internet.
  --no-dev           Skip starting the Vite dev server.
  --force            Overwrite the target directory without prompting.
  --dry-run          Print the plan but do not write or start anything.
  -h, --help         Show this help and exit.

If the target directory already exists, the script prints a warning and
asks whether to (r)efresh in place, (o)verwrite, or (q)uit. The default
in non-interactive mode is "refresh".
EOF
}

die() {
  echo "init.sh: $*" >&2
  exit 1
}

log() {
  echo "init.sh: $*"
}

# Print a numbered choice prompt to stderr; read from /dev/tty so this
# works even when stdin is piped.
SELECTED_CHOICE=""
prompt_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  local input_src="/dev/tty"
  local choice
  echo "$prompt" >&2
  local i=1
  local opt
  for opt in "${options[@]}"; do
    echo "  $i) $opt" >&2
    i=$((i + 1))
  done
  if [ -r "$input_src" ]; then
    read -r -p "Enter choice [1-${#options[@]}]: " choice < "$input_src" 2>/dev/null || choice=""
  else
    echo "Non-interactive shell detected; defaulting to option 1." >&2
    choice=1
  fi
  if [ -z "$choice" ]; then
    choice=1
  fi
  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
    SELECTED_CHOICE="${options[$((choice - 1))]}"
    return 0
  fi
  return 1
}

# sha256sum a file if it exists; otherwise print "none".
file_sha() {
  if [ -e "$1" ]; then
    sha256sum "$1" 2>/dev/null | awk '{print $1}'
  else
    printf 'none'
  fi
}

# -- Argument parsing ------------------------------------------------------

WITH_SAMPLES=false
NO_DEV=false
FORCE=false
DRY_RUN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --target)
      [ $# -ge 2 ] || die "--target requires a value"
      TARGET_DIR="$2"
      shift 2
      ;;
    --target=*)
      TARGET_DIR="${1#*=}"
      shift
      ;;
    --with-samples)
      WITH_SAMPLES=true
      shift
      ;;
    --no-dev)
      NO_DEV=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
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

# -- Pre-flight checks -----------------------------------------------------

# 1. Templates directory must exist.
if [ ! -d "$TEMPLATES_DIR" ]; then
  die "templates directory not found at $TEMPLATES_DIR"
fi

# 2. node -v must report a version >= 18.
if ! command -v node >/dev/null 2>&1; then
  die "node is not on PATH. Install Node.js >= 18 from https://nodejs.org/ and retry."
fi
NODE_VERSION_RAW="$(node -v 2>/dev/null || echo 'v0.0.0')"
NODE_MAJOR="$(printf '%s' "${NODE_VERSION_RAW#v}" | cut -d. -f1)"
if ! [[ "$NODE_MAJOR" =~ ^[0-9]+$ ]] || [ "$NODE_MAJOR" -lt 18 ]; then
  die "node $NODE_VERSION_RAW is too old. Need node >= 18. Install from https://nodejs.org/."
fi
log "node $NODE_VERSION_RAW (>= 18) OK"

# 3. npm must be on PATH.
if ! command -v npm >/dev/null 2>&1; then
  die "npm is not on PATH. Install Node.js >= 18 (which bundles npm) and retry."
fi

# -- Idempotency check: figure out what action to take ---------------------

ACTION=""
if [ -e "$TARGET_DIR" ]; then
  echo "init.sh: WARNING: target directory already exists: $TARGET_DIR" >&2
  if $FORCE; then
    log "--force set; will overwrite the existing directory."
    ACTION="overwrite"
  elif [ -r /dev/tty ]; then
    if prompt_choice "How do you want to handle the existing target?" "refresh" "overwrite" "quit"; then
      ACTION="$SELECTED_CHOICE"
    else
      die "invalid choice; aborting"
    fi
  else
    log "non-interactive mode and --force not set; defaulting to 'refresh'."
    ACTION="refresh"
  fi
else
  ACTION="install"
fi

# -- Dry-run short-circuit ------------------------------------------------

if $DRY_RUN; then
  echo "init.sh plan (dry-run):"
  echo "  source:       $TEMPLATES_DIR"
  echo "  target:       $TARGET_DIR"
  echo "  action:       $ACTION"
  echo "  with-samples: $WITH_SAMPLES"
  echo "  start-dev:    $([ "$NO_DEV" = "false" ] && echo true || echo false)"
  case "$ACTION" in
    install|overwrite)
      echo "  steps:"
      if [ "$ACTION" = "overwrite" ]; then
        echo "    - rm -rf $TARGET_DIR"
      fi
      echo "    - mkdir -p $TARGET_DIR"
      echo "    - cp -R $TEMPLATES_DIR/. $TARGET_DIR/"
      echo "    - (cd $TARGET_DIR && npm install)"
      ;;
    refresh)
      echo "  steps:"
      echo "    - cp -R $TEMPLATES_DIR/. $TARGET_DIR/   (overlay)"
      echo "    - (cd $TARGET_DIR && npm install) [if package.json changed]"
      echo "    - (cd $TARGET_DIR && nohup npm run dev ...) [restart server]"
      ;;
  esac
  if $WITH_SAMPLES && [ -x "$DOWNLOAD_SAMPLES" ]; then
    echo "    - bash $DOWNLOAD_SAMPLES"
  fi
  if [ "$NO_DEV" = "false" ]; then
    echo "    - start Vite dev server on port $PORT (background, log: $LOG_FILE)"
  fi
  exit 0
fi

# -- Install / refresh / overwrite ----------------------------------------

case "$ACTION" in
  install)
    log "creating fresh target at $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    cp -R "$TEMPLATES_DIR/." "$TARGET_DIR/"
    log "copied templates to $TARGET_DIR"
    ;;
  overwrite)
    log "removing existing target at $TARGET_DIR"
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    cp -R "$TEMPLATES_DIR/." "$TARGET_DIR/"
    log "copied templates to $TARGET_DIR"
    ;;
  refresh)
    log "refreshing existing target in place at $TARGET_DIR"
    # cp -R source/. target/ overlays changed files and adds new ones,
    # without removing files that no longer exist in the source.
    cp -R "$TEMPLATES_DIR/." "$TARGET_DIR/"
    log "synced templates into $TARGET_DIR"
    ;;
  quit)
    log "user chose to quit; nothing was changed."
    exit 0
    ;;
  *)
    die "internal error: unknown action '$ACTION'"
    ;;
esac

# -- npm install (idempotent via sha256sum) --------------------------------

SOURCE_PKG_SHA="$(file_sha "$TEMPLATES_DIR/package.json")"
TARGET_PKG_SHA="$(file_sha "$TARGET_DIR/package.json")"

if [ -d "$TARGET_DIR/node_modules" ] \
   && [ "$SOURCE_PKG_SHA" = "$TARGET_PKG_SHA" ] \
   && [ "$SOURCE_PKG_SHA" != "none" ]; then
  log "package.json unchanged and node_modules present; skipping npm install."
else
  log "running npm install in $TARGET_DIR (this may take a minute)..."
  (cd "$TARGET_DIR" && npm install) || die "npm install failed"
fi

# -- Optional sample download ---------------------------------------------

if $WITH_SAMPLES; then
  if [ -x "$DOWNLOAD_SAMPLES" ]; then
    log "running sample downloader (this may take a while)..."
    if ! bash "$DOWNLOAD_SAMPLES"; then
      log "warning: sample download failed; continuing."
    fi
  else
    log "scripts/download-samples.sh is missing or not executable; skipping sample download."
  fi
fi

# -- Start the Vite dev server in the background ---------------------------

if $NO_DEV; then
  log "--no-dev set; skipping Vite start."
else
  # If a previous Vite is still running, stop it. We look in two places:
  # the PID file we wrote on the last run, and anything bound to the port.
  if [ -e "$PID_FILE" ]; then
    OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
      log "stopping previous Vite server (pid $OLD_PID)"
      kill "$OLD_PID" 2>/dev/null || true
      sleep 1
      if kill -0 "$OLD_PID" 2>/dev/null; then
        kill -9 "$OLD_PID" 2>/dev/null || true
      fi
    fi
    rm -f "$PID_FILE"
  fi

  if command -v lsof >/dev/null 2>&1; then
    PORT_PID="$(lsof -ti :"$PORT" 2>/dev/null || true)"
    if [ -n "$PORT_PID" ]; then
      log "port $PORT is in use (pid $PORT_PID); killing it."
      kill "$PORT_PID" 2>/dev/null || true
      sleep 1
      if kill -0 "$PORT_PID" 2>/dev/null; then
        kill -9 "$PORT_PID" 2>/dev/null || true
      fi
    fi
  fi

  log "starting Vite dev server on port $PORT (logs at $LOG_FILE)"
  # Start in a subshell so the parent's CWD is unchanged.
  (
    cd "$TARGET_DIR"
    nohup npm run dev -- --port "$PORT" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
  )

  # Wait briefly for the server to come up.
  for _ in $(seq 1 20); do
    sleep 0.5
    if command -v curl >/dev/null 2>&1 && curl -sI "http://localhost:$PORT/" >/dev/null 2>&1; then
      log "Vite is up at http://localhost:$PORT/"
      break
    fi
  done
fi

# -- Summary ---------------------------------------------------------------

echo
echo "init.sh: Done."
echo "  target:   $TARGET_DIR"
echo "  node:     $NODE_VERSION_RAW"
if [ "$NO_DEV" = "false" ]; then
  echo "  log:      $LOG_FILE"
  echo "  pid file: $PID_FILE"
  echo "  url:      http://localhost:$PORT/"
fi
if $WITH_SAMPLES; then
  echo "  samples:  attempted via scripts/download-samples.sh"
fi
echo
echo "Next steps:"
echo "  1. Open http://localhost:$PORT/ in a browser."
echo "  2. Click the play button inside the strudel.cc iframe once (browser autoplay policy)."
echo "  3. The agent will edit $TARGET_DIR/src/pattern.js in response to your music requests."
