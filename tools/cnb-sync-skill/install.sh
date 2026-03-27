#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./tools/cnb-sync-skill/install.sh [options]

Options:
  --cnb-owner <name>        CNB owner/group for sync target
  --github-owner <name>     GitHub owner for CNB->GitHub sync
  --cnb-imports-url <url>   CNB imports env URL for GitHub credentials
  --write-root-files        Also write root files: .github/workflows/cnb_sync.yml, .cnb.yml, .ide/Dockerfile
  --commit                  Run git add + commit for generated files
  --force                   Overwrite existing target files
  -h, --help                Show this help

Examples:
  ./tools/cnb-sync-skill/install.sh --cnb-owner alice --github-owner alice --write-root-files --commit
  ./tools/cnb-sync-skill/install.sh --cnb-owner team-x --github-owner org-y --cnb-imports-url https://cnb.cool/team-x/keys/-/blob/main/env.yml
EOF
}

CNB_OWNER=""
GITHUB_OWNER=""
CNB_IMPORTS_URL=""
WRITE_ROOT_FILES="false"
DO_COMMIT="false"
FORCE="false"

while (($# > 0)); do
  case "$1" in
    --cnb-owner)
      CNB_OWNER="${2:-}"
      shift 2
      ;;
    --github-owner)
      GITHUB_OWNER="${2:-}"
      shift 2
      ;;
    --cnb-imports-url)
      CNB_IMPORTS_URL="${2:-}"
      shift 2
      ;;
    --write-root-files)
      WRITE_ROOT_FILES="true"
      shift
      ;;
    --commit)
      DO_COMMIT="true"
      shift
      ;;
    --force)
      FORCE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$CNB_OWNER" ]]; then
  echo "Error: --cnb-owner is required" >&2
  exit 1
fi

if [[ -z "$GITHUB_OWNER" ]]; then
  echo "Error: --github-owner is required" >&2
  exit 1
fi

if [[ -z "$CNB_IMPORTS_URL" ]]; then
  CNB_IMPORTS_URL="https://cnb.cool/${CNB_OWNER}/my-keys/-/blob/main/env.yml"
fi

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT_DIR" ]]; then
  echo "Error: this script must run inside a git repository" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"

render_template() {
  local src="$1"
  local dest="$2"

  if [[ -f "$dest" && "$FORCE" != "true" ]]; then
    echo "Skip existing file (use --force to overwrite): $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  local content
  content="$(<"$src")"
  content="${content//\{\{CNB_OWNER\}\}/$CNB_OWNER}"
  content="${content//\{\{GITHUB_OWNER\}\}/$GITHUB_OWNER}"
  content="${content//\{\{CNB_IMPORTS_URL\}\}/$CNB_IMPORTS_URL}"
  printf '%s\n' "$content" > "$dest"

  echo "Wrote: $dest"
}

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Error: template directory not found: $TEMPLATE_DIR" >&2
  exit 1
fi

if [[ "$WRITE_ROOT_FILES" == "true" ]]; then
  render_template "$TEMPLATE_DIR/.github/workflows/cnb_sync.yml.tpl" "$ROOT_DIR/.github/workflows/cnb_sync.yml"
  render_template "$TEMPLATE_DIR/.cnb.yml.tpl" "$ROOT_DIR/.cnb.yml"
  render_template "$TEMPLATE_DIR/.ide/Dockerfile.tpl" "$ROOT_DIR/.ide/Dockerfile"
else
  echo "Template files are available in: $TEMPLATE_DIR"
  echo "Use --write-root-files to materialize files into repository root."
fi

if [[ "$DO_COMMIT" == "true" ]]; then
  git -C "$ROOT_DIR" add .github/workflows/cnb_sync.yml .cnb.yml .ide/Dockerfile tools/cnb-sync-skill 2>/dev/null || \
    git -C "$ROOT_DIR" add tools/cnb-sync-skill
  if git -C "$ROOT_DIR" diff --cached --quiet; then
    echo "No staged changes to commit."
  else
    git -C "$ROOT_DIR" commit -m "chore: add reusable CNB sync skill scaffolding"
    echo "Committed generated changes."
  fi
fi
