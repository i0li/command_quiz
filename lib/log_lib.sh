#!/bin/bash

# ログ出力関数
log() {
  local LEVEL=$1
  local MESSAGE=$2
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LEVEL] $MESSAGE"
}

# TSVデータからログを整形する関数
format_quiz_log() {
  local start_time=$1
  local tsv_data=$2

  # メタデータ（質問と答え）を抽出
  local question=$(echo "$tsv_data" | grep "^META" | grep "question" | cut -f3)
  local answer=$(echo "$tsv_data" | grep "^META" | grep "answer" | cut -f3)

  # TSVエスケープを解除
  question=$(echo "$question" | sed 's/\\t/	/g; s/\\n/\n/g')
  answer=$(echo "$answer" | sed 's/\\t/	/g; s/\\n/\n/g')

  # ログテキストを構築
  printf "[%s]\n" "$start_time"
  printf "Q> %s\n" "$question"
  printf "A> %s\n" "$answer"
  printf "\n"

  # 試行データを処理
  echo "$tsv_data" | grep "^ATTEMPT" | while IFS=$'\t' read -r type num input hint correct; do
    # エスケープ解除
    input=$(echo "$input" | sed 's/\\t/	/g; s/\\n/\n/g')

    # 正解/不正解マーク
    if [ "$correct" = "true" ]; then
      mark="✓"
    else
      mark="✗"
    fi

    # ヒント表示
    if [ "$hint" = "true" ]; then
      hint_label="  [HINT]"
    else
      hint_label=""
    fi

    printf "  #%s  %s  %s%s\n" "$num" "$mark" "$input" "$hint_label"
  done
}

# ログファイルへの書き込み（区切り線付き）
write_to_log_file() {
  local log_file=$1
  local content=$2

  {
    echo "$content"
    echo "─────────────────────────────────────────────────────────────────────────────"
  } >> "$log_file"
}