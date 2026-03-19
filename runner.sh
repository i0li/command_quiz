#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$DIR/logs"
LOG_FILE="$LOG_DIR/$(date '+%Y%m%d').log"

# setup
mkdir -p "$LOG_DIR"
source "$DIR/config.env"

log() {
  LEVEL=$1
  MESSAGE=$2
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LEVEL] $MESSAGE"
}

log INFO "🚀 command-quiz started (PID: $$)"

trap "log INFO '🛑 Stopping...'; exit 0" SIGINT SIGTERM

while true; do
  RANDOM_DELAY=$((MIN_DELAY + RANDOM % (MAX_DELAY - MIN_DELAY + 1)))

  log WAIT "⏳ Sleeping for ${RANDOM_DELAY}s"

  sleep $RANDOM_DELAY

  log RUN "🎯 Starting quiz..."

  # 質問をランダムに選択
  QUESTIONS_FILE="$DIR/questions.yaml"
  QUESTION_COUNT=$(yq eval 'length' "$QUESTIONS_FILE")
  RANDOM_INDEX=$((RANDOM % QUESTION_COUNT))
  QUESTION=$(yq eval ".[$RANDOM_INDEX].q" "$QUESTIONS_FILE")
  ANSWER=$(yq eval ".[$RANDOM_INDEX].a" "$QUESTIONS_FILE")

  # AppleScriptに渡す
  OUTPUT=$(osascript "$DIR/quiz_runner.applescript" "$QUESTION" "$ANSWER" 2>&1)
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    log SUCCESS "✅ Quiz completed"
  else
    log ERROR "❌ Quiz failed"
  fi

  echo "$OUTPUT" | tee -a "$LOG_FILE"

  log INFO "🔁 Cycle complete"
  echo ""
done
