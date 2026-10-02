#!/usr/bin/env bash
# Manual installer for the gaisser-agents catalog (Claude Code and Codex).
# Works with bash 3.2+ on macOS, Linux, and Git Bash on Windows.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'USAGE'
Usage: install.sh [options]

Copies the catalog's agents and skills into a Claude Code and/or Codex setup.
Existing files are never overwritten silently.

Options:
  -l, --list             List the available plugins for the selected target(s) and exit
  -t, --target T         claude (default), codex, or all
  -p, --plugin NAME      Plugin to install (repeatable, or comma-separated)
  -a, --all              Install every plugin
  -b, --base DIR         Home-like root to install into (default: your home folder)
  -A, --agents-only      Codex only: install the agents but not the skill
                         (use this when you installed the Codex plugin)
  -f, --force            Overwrite files that differ (the old copy is moved to a backup folder)
  -n, --dry-run          Show what would happen without changing anything
  -h, --help             Show this help

Destinations (relative to --base):
  claude  agents: .claude/agents/<name>.md        skills: .claude/skills/<skill>/
  codex   agents: .codex/agents/<name>.toml       skills: .agents/skills/<skill>/
          (agents go to $CODEX_HOME/agents when --base is omitted and CODEX_HOME is set)

Exit codes: 0 success, 1 a file operation failed, 2 usage error.
USAGE
}

die_usage() {
  echo "install.sh: $1" >&2
  echo "Try 'install.sh --help'." >&2
  exit 2
}

LIST=0
TARGET="claude"
PLUGINS=""
ALL=0
BASE=""
BASE_GIVEN=0
AGENTS_ONLY=0
FORCE=0
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    -l|--list) LIST=1 ;;
    -t|--target)
      [ $# -ge 2 ] || die_usage "$1 needs a value"
      TARGET="$2"; shift ;;
    -p|--plugin)
      [ $# -ge 2 ] || die_usage "$1 needs a value"
      PLUGINS="$PLUGINS $(echo "$2" | tr ',' ' ')"; shift ;;
    -a|--all) ALL=1 ;;
    -b|--base)
      [ $# -ge 2 ] || die_usage "$1 needs a value"
      BASE="$2"; BASE_GIVEN=1; shift ;;
    -A|--agents-only) AGENTS_ONLY=1 ;;
    -f|--force) FORCE=1 ;;
    -n|--dry-run) DRY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die_usage "unknown option: $1" ;;
  esac
  shift
done

case "$TARGET" in
  claude) TARGETS="claude" ;;
  codex) TARGETS="codex" ;;
  all) TARGETS="claude codex" ;;
  *) die_usage "--target must be claude, codex, or all" ;;
esac

src_root() {
  if [ "$1" = "claude" ]; then echo "$SCRIPT_DIR/dist/claude-code"; else echo "$SCRIPT_DIR/dist/codex"; fi
}

agent_ext() {
  if [ "$1" = "claude" ]; then echo "md"; else echo "toml"; fi
}

# Space-separated plugin names available for a target.
available_plugins() {
  local root d out=""
  root="$(src_root "$1")"
  if [ -d "$root" ]; then
    for d in "$root"/*/; do
      [ -d "$d" ] || continue
      out="$out $(basename "$d")"
    done
  fi
  echo "$out"
}

join_names() {
  local out="" n
  for n in "$@"; do
    if [ -z "$out" ]; then out="$n"; else out="$out, $n"; fi
  done
  echo "$out"
}

plugin_agents() {
  local dir="$(src_root "$1")/$2/agents" ext f names=""
  ext="$(agent_ext "$1")"
  if [ -d "$dir" ]; then
    for f in "$dir"/*."$ext"; do
      [ -f "$f" ] || continue
      names="$names $(basename "$f" ".$ext")"
    done
  fi
  # shellcheck disable=SC2086
  join_names $names
}

plugin_skills() {
  local dir="$(src_root "$1")/$2/skills" d names=""
  if [ -d "$dir" ]; then
    for d in "$dir"/*/; do
      [ -d "$d" ] || continue
      names="$names $(basename "$d")"
    done
  fi
  # shellcheck disable=SC2086
  join_names $names
}

if [ "$LIST" -eq 1 ]; then
  for t in $TARGETS; do
    for p in $(available_plugins "$t"); do
      printf '[%s] %s   agents: %s   skills: %s\n' "$t" "$p" "$(plugin_agents "$t" "$p")" "$(plugin_skills "$t" "$p")"
    done
  done
  exit 0
fi

# Union of valid plugin names across the selected targets.
VALID=""
for t in $TARGETS; do
  for p in $(available_plugins "$t"); do
    case " $VALID " in *" $p "*) ;; *) VALID="$VALID $p" ;; esac
  done
done

if [ "$ALL" -eq 1 ]; then
  SELECTED="$VALID"
else
  SELECTED=""
  for p in $PLUGINS; do
    case " $VALID " in
      *" $p "*) SELECTED="$SELECTED $p" ;;
      *) echo "install.sh: unknown plugin '$p'. Valid plugins:$VALID" >&2; exit 2 ;;
    esac
  done
fi

if [ -z "$(echo "$SELECTED" | tr -d ' ')" ]; then
  echo "No plugin selected. Available plugins:$VALID" >&2
  echo >&2
  usage >&2
  exit 2
fi

# Resolve the base folder.
if [ "$BASE_GIVEN" -eq 0 ]; then
  BASE="${HOME:-}"
fi
BASE="${BASE%/}"
BASE="${BASE%\\}"
if [ -z "$BASE" ]; then
  echo "install.sh: refusing to use an empty or root base folder" >&2
  exit 2
fi
case "$BASE" in
  [A-Za-z]:) echo "install.sh: refusing to use a filesystem root as the base folder" >&2; exit 2 ;;
esac
case "$BASE" in
  /*|[A-Za-z]:/*|[A-Za-z]:\\*) ;;
  *) BASE="$PWD/$BASE" ;;
esac

CODEX_HOME_DIR="$BASE/.codex"
if [ "$BASE_GIVEN" -eq 0 ] && [ -n "${CODEX_HOME:-}" ]; then
  CODEX_HOME_DIR="${CODEX_HOME%/}"
  if [ -z "$CODEX_HOME_DIR" ]; then
    echo "install.sh: refusing to use an empty or root CODEX_HOME" >&2
    exit 2
  fi
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
FAILED=0
PREFIX=""
if [ "$DRY" -eq 1 ]; then PREFIX="[dry-run] "; fi

C_INSTALLED=0; C_UNCHANGED=0; C_SKIPPED=0; C_OVERWRITTEN=0

say() {
  # say STATUS TARGET LABEL [EXTRA]
  if [ -n "${4:-}" ]; then
    printf '%s[%s] %s: %s - %s\n' "$PREFIX" "$1" "$2" "$3" "$4"
  else
    printf '%s[%s] %s: %s\n' "$PREFIX" "$1" "$2" "$3"
  fi
}

do_copy() {
  # do_copy SRC DST RECURSIVE
  if [ "$DRY" -eq 1 ]; then return 0; fi
  mkdir -p "$(dirname "$2")" || return 1
  if [ "$3" = "1" ]; then cp -R "$1" "$2" || return 1; else cp "$1" "$2" || return 1; fi
}

do_backup() {
  # do_backup DST BACKUP_PATH
  if [ "$DRY" -eq 1 ]; then return 0; fi
  mkdir -p "$(dirname "$2")" || return 1
  mv "$1" "$2" || return 1
}

# install_item TARGET KIND LABEL SRC DST COMPARE_SRC COMPARE_DST BACKUP_ROOT
install_item() {
  local target="$1" kind="$2" label="$3" src="$4" dst="$5" csrc="$6" cdst="$7" broot="$8"
  local rec=0
  if [ "$kind" = "skill" ]; then rec=1; fi
  if [ ! -e "$dst" ]; then
    if do_copy "$src" "$dst" "$rec"; then
      say installed "$target" "$label"; C_INSTALLED=$((C_INSTALLED + 1))
    else
      say failed "$target" "$label" "copy failed"; FAILED=1
    fi
  elif [ -f "$cdst" ] && cmp -s "$csrc" "$cdst"; then
    say unchanged "$target" "$label"; C_UNCHANGED=$((C_UNCHANGED + 1))
  elif [ "$FORCE" -eq 0 ]; then
    say skipped "$target" "$label" "differs from this repo's version (use --force to overwrite)"
    C_SKIPPED=$((C_SKIPPED + 1))
  else
    local bpath="$broot/agent-catalog-backups/$STAMP/$label"
    if do_backup "$dst" "$bpath" && do_copy "$src" "$dst" "$rec"; then
      say "overwritten (backup: $bpath)" "$target" "$label"; C_OVERWRITTEN=$((C_OVERWRITTEN + 1))
    else
      say failed "$target" "$label" "backup or copy failed"; FAILED=1
    fi
  fi
}

for t in $TARGETS; do
  C_INSTALLED=0; C_UNCHANGED=0; C_SKIPPED=0; C_OVERWRITTEN=0
  if [ "$t" = "claude" ]; then
    AGENTS_DST="$BASE/.claude/agents"
    SKILLS_DST="$BASE/.claude/skills"
    BROOT="$BASE/.claude"
  else
    AGENTS_DST="$CODEX_HOME_DIR/agents"
    SKILLS_DST="$BASE/.agents/skills"
    BROOT="$CODEX_HOME_DIR"
  fi
  ext="$(agent_ext "$t")"
  for p in $SELECTED; do
    pdir="$(src_root "$t")/$p"
    [ -d "$pdir" ] || continue
    if [ -d "$pdir/agents" ]; then
      for f in "$pdir/agents"/*."$ext"; do
        [ -f "$f" ] || continue
        fn="$(basename "$f")"
        install_item "$t" agent "agents/$fn" "$f" "$AGENTS_DST/$fn" "$f" "$AGENTS_DST/$fn" "$BROOT"
      done
    fi
    if [ -d "$pdir/skills" ] && { [ "$t" != "codex" ] || [ "$AGENTS_ONLY" -eq 0 ]; }; then
      for d in "$pdir/skills"/*/; do
        [ -d "$d" ] || continue
        sn="$(basename "$d")"
        install_item "$t" skill "skills/$sn/" "${d%/}" "$SKILLS_DST/$sn" "$d/SKILL.md" "$SKILLS_DST/$sn/SKILL.md" "$BROOT"
      done
    fi
  done
  echo "$t: Installed: $C_INSTALLED, unchanged: $C_UNCHANGED, skipped: $C_SKIPPED, overwritten: $C_OVERWRITTEN"
done

if [ "$DRY" -eq 0 ] && [ "$FAILED" -eq 0 ]; then
  echo
  echo "Restart the tool (or start a new session) to load new agents and skills."
  echo "Claude manual installs are not namespaced: use 'architect', not 'dev-pipeline:architect'; the skill is /pipeline."
  echo "In Codex the skill is invoked as \$pipeline."
  echo "To update later: git pull, then re-run this script with --force."
fi

if [ "$FAILED" -ne 0 ]; then exit 1; fi
exit 0
