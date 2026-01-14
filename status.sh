#!/bin/bash
# Check agent status

cd "$(dirname "$0")" || exit 1

echo "═══════════════════════════════════════════"
echo "COMPETITOR INTELLIGENCE AGENT STATUS"
echo "═══════════════════════════════════════════"

# Last briefing
LATEST=$(ls -t output/briefings/*.md 2>/dev/null | head -1)
if [ -n "$LATEST" ]; then
  DATE=$(basename "$LATEST" .md)
  echo "Last briefing: $DATE"
else
  echo "Last briefing: None"
fi

# Competitors tracked
if [ -f "competitors.md" ]; then
  COUNT=$(grep -c "^[a-z]" competitors.md 2>/dev/null || echo "0")
  echo "Competitors tracked: $((COUNT - 1))"
fi

# Agent status
if [ -d ".agent.lock.d" ]; then
  echo "Agent status: Running"
else
  echo "Agent status: Idle"
fi

echo "═══════════════════════════════════════════"
