#!/bin/bash
# Claude Code Status Line - カラー版（zsh RPROMPT互換）

input=$(cat)

# 色定義
CYAN='\033[36m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# モデル名
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# 現在のディレクトリ（短縮形） - zsh %~ と同じ
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
if [[ "$CURRENT_DIR" == "$HOME"* ]]; then
  DIR_NAME="~${CURRENT_DIR#$HOME}"
else
  DIR_NAME="$CURRENT_DIR"
fi

# Gitブランチ + ステータス - zsh vcs_info と同じ表示
GIT_INFO=""
if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
    BRANCH=$(cd "$CURRENT_DIR" && git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        STAGED=""
        UNSTAGED=""
        # staged changes → 黄 !（zsh stagedstr と同じ）
        if cd "$CURRENT_DIR" && git diff --cached --quiet 2>/dev/null; [ $? -eq 1 ]; then
            STAGED="${YELLOW}!"
        fi
        # unstaged changes → 赤 +（zsh unstagedstr と同じ）
        if cd "$CURRENT_DIR" && git diff --quiet 2>/dev/null; [ $? -eq 1 ]; then
            UNSTAGED="${RED}+"
        fi
        GIT_INFO="${GREEN}${STAGED}${UNSTAGED}[${BRANCH}]${RESET}"
    fi
fi

# コスト情報
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf "%.2f" "$COST")

# 追加・削除行数
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# コンテキストウィンドウ使用率
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
if [ "$CONTEXT_SIZE" -gt 0 ]; then
    PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
else
    PERCENT_USED=0
fi

# コンテキスト使用率に応じた色
if [ "$PERCENT_USED" -ge 90 ]; then
    CTX_COLOR="$RED"
elif [ "$PERCENT_USED" -ge 70 ]; then
    CTX_COLOR="$YELLOW"
else
    CTX_COLOR="$GREEN"
fi

# 出力を組み立て
# 動的に色が変わる: Gitステータス（!黄/+赤）、コンテキスト使用率（緑→黄→赤）
# それ以外は色なし
OUTPUT="[$MODEL] [${DIR_NAME}]"

if [ -n "$GIT_INFO" ]; then
    OUTPUT="$OUTPUT ${GIT_INFO}"
fi

# トークン数を読みやすい形式に（例: 45.2k, 200.0k）
TOKENS_K=$(awk "BEGIN {printf \"%.1f\", $CURRENT_TOKENS / 1000}")
SIZE_K=$(awk "BEGIN {printf \"%.0f\", $CONTEXT_SIZE / 1000}")

OUTPUT="$OUTPUT | +$LINES_ADDED -$LINES_REMOVED | ${CTX_COLOR}ctx:${TOKENS_K}k/${SIZE_K}k(${PERCENT_USED}%)${RESET} | \$$COST_FMT"

echo -e "$OUTPUT"
