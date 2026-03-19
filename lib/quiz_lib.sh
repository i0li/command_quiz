#!/bin/bash

# YAMLファイルからランダムに質問を選択する関数
select_random_question() {
  local questions_file=$1

  # 質問数を取得
  local question_count=$(yq eval 'length' "$questions_file")

  # ランダムインデックスを生成
  local random_index=$((RANDOM % question_count))

  # 質問と答えを取得
  local question=$(yq eval ".[$random_index].q" "$questions_file")
  local answer=$(yq eval ".[$random_index].a" "$questions_file")

  # タブ区切りで返す（1行で）
  echo "$question	$answer"
}

# クイズを実行する関数
run_quiz() {
  local dir=$1
  local question=$2
  local answer=$3

  # AppleScriptを実行してTSVデータを取得
  local tsv_output=$(osascript "$dir/quiz_runner.applescript" "$question" "$answer" 2>&1)
  local status=$?

  # 結果を出力
  echo "$tsv_output"
  return $status
}

# 遅延時間を計算する関数
get_random_delay() {
  local min_delay=$1
  local max_delay=$2

  echo $((min_delay + RANDOM % (max_delay - min_delay + 1)))
}