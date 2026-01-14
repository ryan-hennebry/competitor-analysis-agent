#!/bin/bash
# Run the competitor intelligence agent

cd "$(dirname "$0")" || { echo "Failed to change directory"; exit 1; }

LOCKDIR=".agent.lock.d"

# Atomic lock acquisition using mkdir
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  if [ -f "$LOCKDIR/pid" ]; then
    LOCK_AGE=$(($(date +%s) - $(stat -f %m "$LOCKDIR/pid")))
    if [ "$LOCK_AGE" -lt 3600 ]; then
      echo "Agent already running (lock age: ${LOCK_AGE}s). Exiting."
      exit 1
    else
      echo "Stale lock detected (${LOCK_AGE}s old). Removing."
      rm -rf "$LOCKDIR"
      mkdir "$LOCKDIR" || { echo "Failed to acquire lock"; exit 1; }
    fi
  else
    rm -rf "$LOCKDIR"
    mkdir "$LOCKDIR" || { echo "Failed to acquire lock"; exit 1; }
  fi
fi

echo $$ > "$LOCKDIR/pid"

cleanup() {
  rm -rf "$LOCKDIR"
}
trap cleanup EXIT

# Run agent — fewer tool restrictions, more autonomy
claude -p "Run the competitor intelligence agent" --allowedTools "WebFetch,Read,Write,Glob,Bash,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__get_page_text"

# Deliver the briefing
echo ""
echo "Running delivery..."
./scripts/deliver.sh
