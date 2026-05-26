#!/usr/bin/env bash
#
# capture-lesson.sh — Interactive lesson capture for az-investigator.
#
# Prompts for the 6 fields needed by templates/lesson.md, writes a stub
# file, and appends a row to LESSONS_INDEX.md + BACKLOG.md if severity warrants.
#
# Usage: bash harness/scripts/capture-lesson.sh
#        echo -e "summary\ntool\nseverity\ncost_min\ntrigger_phrase" \
#          | bash harness/scripts/capture-lesson.sh   # for non-interactive

set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
HARNESS="$SKILL_ROOT/harness"
[[ -d "$HARNESS" ]] || { echo "ERR: harness dir not found at $HARNESS" >&2; exit 2; }

prompt() {
  local var="$1"; local question="$2"; local default="${3:-}"
  if [[ -t 0 ]]; then
    if [[ -n "$default" ]]; then
      read -rp "$question [$default]: " v
    else
      read -rp "$question: " v
    fi
  else
    read -r v
  fi
  printf -v "$var" '%s' "${v:-$default}"
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' \
    | cut -c1-60
}

today() { date -u +%Y-%m-%d; }

prompt SUMMARY "One-line lesson summary"
[[ -n "$SUMMARY" ]] || { echo "ERR: summary required" >&2; exit 2; }

prompt TOOL "Tool / file / quirk this is about" ""
prompt SEVERITY "Severity (cosmetic | annoying | data-corrupting | reasoning-error)" "annoying"
prompt COST "Cost first time in minutes (integer)" "10"
prompt TRIGGER "Trigger phrase someone would search for"

case "$SEVERITY" in
  cosmetic|annoying|data-corrupting|reasoning-error) ;;
  *) echo "ERR: severity must be cosmetic / annoying / data-corrupting / reasoning-error" >&2; exit 2 ;;
esac

SLUG="$(slugify "$SUMMARY")"
DATE="$(today)"
LESSON_FILE="$HARNESS/lessons/${DATE}-${SLUG}.md"
INDEX="$HARNESS/LESSONS_INDEX.md"
BACKLOG="$HARNESS/BACKLOG.md"

if [[ -e "$LESSON_FILE" ]]; then
  echo "ERR: lesson file already exists: $LESSON_FILE" >&2
  echo "     Edit the existing file or pick a different summary." >&2
  exit 3
fi

CAPTURED_BY="${USER:-${LOGNAME:-agent}}"
sed "s/{{TITLE}}/$SUMMARY/g; \
     s/{{YYYY-MM-DD}}/$DATE/g; \
     s/{{AGENT_OR_HUMAN}}/$CAPTURED_BY/g; \
     s/{{MINUTES}}/$COST/g; \
     s|{{e.g. run-kql.sh, AppRequests schema, Mermaid syntax}}|$TOOL|g; \
     s|{{search phrases someone would type when hitting this again}}|$TRIGGER|g" \
  "$HARNESS/templates/lesson.md" > "$LESSON_FILE"

NEXT_NUM=$(grep -cE '^\| L[0-9]+' "$INDEX" 2>/dev/null || echo 0)
NEXT_NUM=$((NEXT_NUM + 1))
LNN=$(printf "L%02d" "$NEXT_NUM")

ROW="| $LNN | $DATE | [${SLUG}](lessons/${DATE}-${SLUG}.md) | $SEVERITY | ${COST}min | 📥 captured | — |"
echo "$ROW" >> "$INDEX"

case "$SEVERITY" in
  cosmetic) ;;
  *)
    {
      echo ""
      echo "| ${LNN} | [${SLUG}](lessons/${DATE}-${SLUG}.md) | tbd | ${SEVERITY} — captured ${DATE} |"
    } >> "$BACKLOG"
    ;;
esac

echo ""
echo "✅ Lesson captured: $LESSON_FILE"
echo "   Indexed as: $LNN"
echo "   Severity: $SEVERITY"
echo ""
echo "Next steps:"
echo "  1. Fill in the body of $LESSON_FILE (expected vs actual vs diagnosis)"
case "$SEVERITY" in
  cosmetic) echo "  2. (cosmetic — no backlog entry created)" ;;
  *) echo "  2. When ready, promote via: bash harness/scripts/promote-to-story.sh $LESSON_FILE" ;;
esac
