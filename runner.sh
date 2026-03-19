#!/bin/bash

# ディレクトリとファイル設定
DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$DIR/logs"
LOG_FILE="$LOG_DIR/$(date '+%Y%m%d').log"

# セットアップ
mkdir -p "$LOG_DIR"

# 設定とライブラリを読み込み
source "$DIR/config.env"
source "$DIR/lib/log_lib.sh"
source "$DIR/lib/quiz_lib.sh"

# 開始メッセージ
log INFO "🚀 command-quiz started (PID: $$)"

# 終了処理
trap "log INFO '🛑 Stopping...'; exit 0" SIGINT SIGTERM

# メインループ
while true; do
  # ランダムな遅延時間を計算
  RANDOM_DELAY=$(get_random_delay "$MIN_DELAY" "$MAX_DELAY")

  log WAIT "⏳ Sleeping for ${RANDOM_DELAY}s"
  sleep $RANDOM_DELAY

  log RUN "🎯 Starting quiz..."

  # 開始時刻を記録
  START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

  # 質問をランダムに選択
  QUESTIONS_FILE="$DIR/questions.yaml"
  QUIZ_DATA=$(select_random_question "$QUESTIONS_FILE")
  QUESTION=$(echo "$QUIZ_DATA" | cut -f1)
  ANSWER=$(echo "$QUIZ_DATA" | cut -f2)

  # クイズを実行
  TSV_OUTPUT=$(run_quiz "$DIR" "$QUESTION" "$ANSWER")
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    log SUCCESS "✅ Quiz completed"

    # TSVデータをログ形式に整形
    FORMATTED_LOG=$(format_quiz_log "$START_TIME" "$TSV_OUTPUT")

    # シェルに出力（前後に空白行）
    echo ""
    echo "$FORMATTED_LOG"
    echo ""

    # ログファイルに書き込み
    write_to_log_file "$LOG_FILE" "$FORMATTED_LOG"
  else
    log ERROR "❌ Quiz failed"
    echo ""
    echo "Error: $TSV_OUTPUT"
    echo ""
  fi

  log INFO "🔁 Cycle complete"
  echo "─────────────────────────────────────────────────────────────────────────────"
done