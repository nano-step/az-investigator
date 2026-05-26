#!/usr/bin/env bash
#
# promote-to-story.sh — Convert a captured lesson into an actionable story.
#
# Usage: bash harness/scripts/promote-to-story.sh <path-to-lesson.md>
#
# Picks the next STORY-NN number, copies templates/story.md with substitutions,
# updates LESSONS_INDEX.md status, and inserts a row into BACKLOG.md "In-progress".
# Default lane is "normal" — bump to "high-risk" if the lesson severity is
# data-corrupting or reasoning-error.

set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
HARNESS="$SKILL_ROOT/harness"

LESSON_PATH="${1:-}"
[[ -n "$LESSON_PATH" && -f "$LESSON_PATH" ]] || {
  echo "Usage: $0 <path-to-lesson.md>" >&2
  exit 2
}

LESSON_BASENAME="$(basename "$LESSON_PATH" .md)"
LESSON_REL="$(realpath --relative-to="$HARNESS" "$LESSON_PATH")"
SLUG="${LESSON_BASENAME#*-*-*-}"

NEXT=$(find "$HARNESS/stories" -maxdepth 1 -name 'STORY-*.md' 2>/dev/null | wc -l)
NEXT=$((NEXT + 1))
NN=$(printf "%02d" "$NEXT")

SEVERITY=""
if grep -q '| \*\*Severity\*\*' "$LESSON_PATH"; then
  SEVERITY=$(grep -E '^\| \*\*Severity\*\*' "$LESSON_PATH" | head -1 | awk -F '|' '{print $3}' | tr -d ' ')
fi
case "$SEVERITY" in
  data-corrupting|reasoning-error) DEFAULT_LANE="high-risk" ;;
  *) DEFAULT_LANE="normal" ;;
esac

LANE="${LANE:-$DEFAULT_LANE}"
CHANGE_TYPE="${CHANGE_TYPE:-skill-content}"

STORY_FILE="$HARNESS/stories/STORY-${NN}-${SLUG}.md"
if [[ -e "$STORY_FILE" ]]; then
  echo "ERR: story file already exists: $STORY_FILE" >&2
  exit 3
fi

TITLE=$(grep -m1 '^# Lesson:' "$LESSON_PATH" | sed 's/^# Lesson: //')
TODAY=$(date -u +%Y-%m-%d)

sed "s/{{NN}}/${NN}/g; \
     s/{{TITLE}}/${TITLE}/g; \
     s/{{YYYY-MM-DD}}/${TODAY}/g; \
     s|{{file}}|${LESSON_BASENAME}|g" \
  "$HARNESS/templates/story.md" \
  | sed "s/tiny \/ normal \/ high-risk/${LANE}/" \
  | sed "s/skill-content \/ script \/ query \/ response-shape \/ test \/ publish/${CHANGE_TYPE}/" \
  > "$STORY_FILE"

if grep -q "${LESSON_BASENAME}" "$HARNESS/LESSONS_INDEX.md"; then
  sed -i.bak "s|\(${LESSON_BASENAME}.*\)📥 captured\(.*\)— |\1🛠️ promoted\2[STORY-${NN}](stories/STORY-${NN}-${SLUG}.md) |" \
    "$HARNESS/LESSONS_INDEX.md"
  rm -f "$HARNESS/LESSONS_INDEX.md.bak"
fi

if ! grep -q "## In-progress" "$HARNESS/BACKLOG.md"; then
  echo "## In-progress" >> "$HARNESS/BACKLOG.md"
fi
sed -i.bak "/^## In-progress$/a\\
| STORY-${NN} | [${SLUG}](stories/STORY-${NN}-${SLUG}.md) | ${LANE} | promoted ${TODAY} |" \
  "$HARNESS/BACKLOG.md" 2>/dev/null || true
rm -f "$HARNESS/BACKLOG.md.bak"

echo ""
echo "✅ Promoted lesson to story: $STORY_FILE"
echo "   Lane: $LANE"
echo "   Change type: $CHANGE_TYPE"
echo ""
echo "Next steps:"
echo "  1. Fill in Goal / Non-goals / Acceptance criteria in $STORY_FILE"
echo "  2. Implement the change"
echo "  3. bash harness/scripts/run-tests.sh smoke"
echo "  4. bash harness/scripts/gate-check.sh"
