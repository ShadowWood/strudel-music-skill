#!/usr/bin/env bash
# scripts/download-samples.sh - Mirror the upstream tidal-drum-machines
# sample-bank manifest into the local strudel-music player.
#
# The script:
#   1. Downloads the JSON manifest from
#      https://codeberg.org/uzu/strudel/raw/branch/main/website/public/tidal-drum-machines.json
#   2. Parses it with python3 (urllib.parse.quote + urllib.request).
#   3. For every relative path in the manifest, builds a URL of the form
#      https://raw.githubusercontent.com/geikha/tidal-drum-machines/main/machines/<urlencoded-relative-path>
#      and downloads it into ${HOME}/strudel-music/public/samples/<relative-path>.
#   4. Skips any file that already exists locally with the same size as the
#      upstream Content-Length (so re-running is cheap).
#
# Network errors are non-fatal: a failed manifest download exits 0 with a
# warning so scripts/init.sh can continue. A failed individual file is
# logged and counted, but the script still tries the rest of the manifest.

set -euo pipefail

# -- Configuration ---------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MANIFEST_URL="https://codeberg.org/uzu/strudel/raw/branch/main/website/public/tidal-drum-machines.json"
AUDIO_BASE_URL="https://raw.githubusercontent.com/geikha/tidal-drum-machines/main/machines"

# Defaults; can be overridden by --target.
TARGET_DIR="${HOME}/strudel-music"
SAMPLES_DIR="${TARGET_DIR}/public/samples"
LOG_FILE="${HOME}/strudel-music-download.log"

# -- Helpers ---------------------------------------------------------------

print_usage() {
  cat <<'EOF'
Usage: bash scripts/download-samples.sh [options]

Options:
  --target <path>    Install the samples under a different player root
                     (default: ~/strudel-music). The samples always land in
                     <target>/public/samples/.
  --dry-run          Print the manifest summary and planned file count, but
                     do not download or write anything.
  --log              Also append a timestamped log line to
                     ~/strudel-music-download.log.
  -h, --help         Show this help and exit.

The script is idempotent: re-running skips every file that is already
present with the upstream's Content-Length. A failed manifest download
prints a warning and exits 0 so scripts/init.sh can keep going.
EOF
}

die() {
  echo "download-samples.sh: $*" >&2
  exit 1
}

log() {
  echo "download-samples.sh: $*"
}

# -- Argument parsing ------------------------------------------------------

DRY_RUN=false
WRITE_LOG=false

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
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --log)
      WRITE_LOG=true
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

# Re-derive SAMPLES_DIR after parsing in case --target was passed.
SAMPLES_DIR="${TARGET_DIR%/}/public/samples"

# -- Pre-flight checks -----------------------------------------------------

if ! command -v python3 >/dev/null 2>&1; then
  die "python3 is not on PATH. Install Python 3 and retry."
fi
if ! command -v curl >/dev/null 2>&1; then
  die "curl is not on PATH. Install curl and retry."
fi

# -- Fetch the manifest ----------------------------------------------------

MANIFEST_TMP="$(mktemp)"
trap 'rm -f "$MANIFEST_TMP"' EXIT

log "fetching manifest from $MANIFEST_URL"
if ! curl -sSf --max-time 30 -o "$MANIFEST_TMP" "$MANIFEST_URL"; then
  log "manifest download failed, skipping samples (init.sh will continue)"
  exit 0
fi

if [ ! -s "$MANIFEST_TMP" ]; then
  log "manifest is empty, skipping samples"
  exit 0
fi

# -- Dry-run short-circuit -------------------------------------------------

if $DRY_RUN; then
  log "dry-run: would download samples into $SAMPLES_DIR"
  python3 - "$MANIFEST_TMP" "$AUDIO_BASE_URL" "$SAMPLES_DIR" "true" <<'PYEOF' || true
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    manifest = json.load(f)

paths = [p for ps in manifest.values() for p in ps]
banks = len(manifest)
files = sum(1 for p in paths if p.lower().endswith(".wav"))
print(f"manifest: {banks} banks, {files} .wav files")
print(f"target:   {sys.argv[3]}")
print(f"audio base: {sys.argv[2]}")
print("first 3 sample URLs (URL-encoded with urllib.parse.quote):")
import urllib.parse
for p in paths[:3]:
    enc = urllib.parse.quote(p, safe="/")
    print(f"  {sys.argv[2]}/{enc}")
PYEOF
  exit 0
fi

# -- Ensure target directory exists ----------------------------------------

mkdir -p "$SAMPLES_DIR"

# -- Download via python3 --------------------------------------------------
# All real work (JSON parse, URL build, HEAD probe, GET, size check) is
# done in python3 so we get urllib.parse.quote for free and avoid shell
# quoting bugs around paths with spaces ("Closed Hat.wav").

log "downloading samples into $SAMPLES_DIR"
python3 - "$MANIFEST_TMP" "$AUDIO_BASE_URL" "$SAMPLES_DIR" "false" <<'PYEOF'
import json
import os
import ssl
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request

manifest_path, base_url, samples_dir, _ = sys.argv[1:5]

with open(manifest_path, "r", encoding="utf-8") as f:
    manifest = json.load(f)

# Flatten the manifest to a list of relative paths, preserving manifest
# order (so any failure is reported in a stable, deterministic sequence).
all_paths = []
for bank in manifest:
    for p in manifest[bank]:
        all_paths.append(p)

# Only .wav files are downloaded; other extensions in the manifest (if any
# ever appear) are reported but skipped.
wav_paths = [p for p in all_paths if p.lower().endswith(".wav")]
print(f"manifest: {len(manifest)} banks, {len(wav_paths)} .wav files")

downloaded = 0
skipped = 0
failed = 0
ctx = ssl.create_default_context()
timeout = 30

for rel_path in wav_paths:
    # URL-encode the path: keep '/' as a separator, encode everything else
    # (so 'Closed Hat.wav' becomes 'Closed%20Hat.wav').
    encoded = urllib.parse.quote(rel_path, safe="/")
    url = f"{base_url}/{encoded}"

    local_path = os.path.join(samples_dir, rel_path)
    local_dir = os.path.dirname(local_path)

    try:
        os.makedirs(local_dir, exist_ok=True)
    except OSError as e:
        print(f"  fail   {rel_path}: mkdir {local_dir}: {e}", file=sys.stderr)
        failed += 1
        continue

    # Probe the upstream size with HEAD. If the local file already has
    # that size, skip without downloading.
    expected_size = None
    try:
        req = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
            cl = resp.headers.get("Content-Length")
            if cl is not None:
                expected_size = int(cl)
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, ValueError) as e:
        # HEAD failed; we will still try the GET below.
        print(f"  warn   {rel_path}: HEAD {type(e).__name__}: {e}", file=sys.stderr)

    if expected_size and os.path.exists(local_path):
        try:
            actual_size = os.path.getsize(local_path)
        except OSError:
            actual_size = -1
        if actual_size == expected_size:
            print(f"  skip   {rel_path} (already {actual_size} bytes)")
            skipped += 1
            continue

    # Download to a temp file inside the destination directory, then move
    # it into place atomically with os.replace.
    tmp_fd = None
    tmp_path = None
    try:
        with urllib.request.urlopen(url, timeout=timeout * 2, context=ctx) as resp:
            data = resp.read()
        actual_size = len(data)

        if expected_size and actual_size != expected_size:
            print(
                f"  warn   {rel_path}: size mismatch (HEAD={expected_size}, GET={actual_size})",
                file=sys.stderr,
            )

        tmp_fd, tmp_path = tempfile.mkstemp(dir=local_dir, prefix=".dl-", suffix=".tmp")
        with os.fdopen(tmp_fd, "wb") as tmp_f:
            tmp_f.write(data)
            tmp_f.flush()
            try:
                os.fsync(tmp_f.fileno())
            except OSError:
                # fsync is best-effort.
                pass
        os.replace(tmp_path, local_path)
        tmp_path = None  # consumed by os.replace
        print(f"  ok     {rel_path} ({actual_size} bytes)")
        downloaded += 1
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, OSError) as e:
        print(f"  fail   {rel_path}: {type(e).__name__}: {e}", file=sys.stderr)
        failed += 1
        if tmp_path and os.path.exists(tmp_path):
            try:
                os.unlink(tmp_path)
            except OSError:
                pass

print()
print(f"summary: downloaded={downloaded}, skipped={skipped}, failed={failed}")
PYEOF
PYTHON_EXIT=$?

# -- Optional log line -----------------------------------------------------

if $WRITE_LOG; then
  printf '[%s] target=%s samples_dir=%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$TARGET_DIR" \
    "$SAMPLES_DIR" \
    >> "$LOG_FILE" 2>/dev/null || true
fi

log "Done."
exit $PYTHON_EXIT
