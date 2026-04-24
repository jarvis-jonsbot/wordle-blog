#!/usr/bin/env bash
# Generate a Wordle blog post with all required frontmatter.
# Usage: new-post.sh <puzzle_num> <answer> <guesses_used> <solved> <emoji_grid> [body_text]
#
# Args:
#   puzzle_num   - Wordle puzzle number (days_since_launch)
#   answer       - Answer word (uppercase)
#   guesses_used - Number of guesses (1-6, or 0 if failed)
#   solved       - "true" or "false"
#   emoji_grid   - Emoji grid, rows separated by newlines
#   body_text    - Optional blog post body (2-3 paragraphs)
#
# Example:
#   new-post.sh 1770 DRUNK 3 true $'⬛⬛⬛⬛⬛\n⬛⬛🟨🟩⬛\n🟩🟩🟩🟩🟩' "First paragraph..."

set -euo pipefail

PUZZLE_NUM="${1:?puzzle_num required}"
ANSWER="${2:?answer required}"
GUESSES="${3:?guesses_used required}"
SOLVED="${4:?solved (true/false) required}"
EMOJI_GRID="${5:?emoji_grid required}"
BODY="${6:-}"

TODAY=$(date +%Y-%m-%d)
ANSWER_LOWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')

if [ "$SOLVED" = "true" ]; then
  SCORE="${GUESSES}/6"
else
  SCORE="X/6"
fi

BLOG_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FILENAME="_posts/${TODAY}-wordle-${PUZZLE_NUM}-${ANSWER_LOWER}.md"
FILEPATH="${BLOG_DIR}/${FILENAME}"

# Build share_text with proper indentation
SHARE_TEXT="Wordle ${PUZZLE_NUM} ${SCORE}"
while IFS= read -r row; do
  SHARE_TEXT="${SHARE_TEXT}
  ${row}"
done <<< "$EMOJI_GRID"

cat > "$FILEPATH" <<EOF
---
layout: post
title: "Wordle #${PUZZLE_NUM}: ${ANSWER} (${SCORE})"
date: ${TODAY} 07:00:00 -0700
wordle_number: ${PUZZLE_NUM}
answer: ${ANSWER}
solved: ${SOLVED}
guesses: ${GUESSES}
share_text: |
  ${SHARE_TEXT}
---

${BODY}
EOF

# Validate all 5 required fields are present
COUNT=$(grep -c 'wordle_number:\|answer:\|solved:\|guesses:\|share_text:' "$FILEPATH")
if [ "$COUNT" -ne 5 ]; then
  echo "ERROR: Post validation failed — expected 5 required fields, found ${COUNT}" >&2
  echo "File: ${FILEPATH}" >&2
  cat "$FILEPATH" >&2
  exit 1
fi

echo "OK: ${FILEPATH}"
