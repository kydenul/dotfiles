#!/bin/bash
# agent-skills session start hook
# Injects the using-agent-skills meta-skill into every new session

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"
META_SKILL="$SKILLS_DIR/using-agent-skills/SKILL.md"

if [ -f "$META_SKILL" ]; then
  # Output as JSON for Claude Code hook consumption
  # Use jq to properly escape the markdown content into a valid JSON string
  MESSAGE=$(printf 'agent-skills loaded. Use the skill discovery flowchart to find the right skill for your task.\n\n%s' "$(cat "$META_SKILL")")
  jq -n --arg msg "$MESSAGE" '{"priority": "IMPORTANT", "message": $msg}'
else
  echo '{"priority": "INFO", "message": "agent-skills: using-agent-skills meta-skill not found. Skills may still be available individually."}'
fi
