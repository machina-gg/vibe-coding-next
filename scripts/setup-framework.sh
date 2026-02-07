#!/bin/bash
set -euo pipefail

# =============================================================================
# setup-framework.sh
# vibe-coding-utils のフレームワーク別セットアップスクリプト
#
# Usage:
#   bash .claude/vibe-coding-utils/scripts/setup-framework.sh nextjs
#   bash .claude/vibe-coding-utils/scripts/setup-framework.sh chrome-extension
# =============================================================================

FRAMEWORK="${1:-}"

if [ -z "$FRAMEWORK" ]; then
  echo "Usage: $0 <nextjs|chrome-extension>"
  echo ""
  echo "Available frameworks:"
  echo "  nextjs            - Next.js (App Router) プロジェクト"
  echo "  chrome-extension  - Chrome拡張 (Plasmo) プロジェクト"
  exit 1
fi

# フレームワーク名のバリデーション
case "$FRAMEWORK" in
  nextjs|chrome-extension)
    ;;
  *)
    echo "Error: Unknown framework '$FRAMEWORK'"
    echo "Available: nextjs, chrome-extension"
    exit 1
    ;;
esac

# スクリプトの場所からベースディレクトリを特定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# プロジェクトルートを特定（subtree の場合は .claude/vibe-coding-utils/ の2つ上）
# スクリプトが直接実行される場合と subtree 経由の場合の両方に対応
if [[ "$BASE_DIR" == *".claude/vibe-coding-utils"* ]]; then
  PROJECT_ROOT="$(cd "$BASE_DIR/../.." && pwd)"
else
  PROJECT_ROOT="$(cd "$BASE_DIR" && pwd)"
fi

# CLAUDE_TEMPLATE 変数の設定
case "$FRAMEWORK" in
  nextjs)
    CLAUDE_TEMPLATE="CLAUDE_NEXTJS.md"
    ;;
  chrome-extension)
    CLAUDE_TEMPLATE="CLAUDE_CHROME_EXT.md"
    ;;
esac

echo "========================================="
echo "vibe-coding-utils setup"
echo "Framework: $FRAMEWORK"
echo "Base dir:  $BASE_DIR"
echo "Project:   $PROJECT_ROOT"
echo "========================================="
echo ""

# 1. コマンドディレクトリの作成
COMMANDS_DEST="$PROJECT_ROOT/.claude/commands/project"
mkdir -p "$COMMANDS_DEST"

# 2. shared コマンドをコピー
echo "[1/3] Copying shared commands..."
for file in "$BASE_DIR/commands/shared/"*.md; do
  if [ -f "$file" ]; then
    cp "$file" "$COMMANDS_DEST/"
    echo "  -> $(basename "$file")"
  fi
done

# 3. フレームワーク固有コマンドをコピー
echo "[2/3] Copying $FRAMEWORK commands..."
for file in "$BASE_DIR/commands/$FRAMEWORK/"*.md; do
  if [ -f "$file" ]; then
    cp "$file" "$COMMANDS_DEST/"
    echo "  -> $(basename "$file")"
  fi
done

# 4. CLAUDE.md を生成（BASE + フレームワーク固有を結合）
echo "[3/3] Generating CLAUDE.md..."
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

cat "$BASE_DIR/templates/CLAUDE_BASE.md" > "$CLAUDE_MD"
echo "" >> "$CLAUDE_MD"
cat "$BASE_DIR/templates/$CLAUDE_TEMPLATE" >> "$CLAUDE_MD"

echo "  -> CLAUDE.md generated"

echo ""
echo "========================================="
echo "Setup complete!"
echo ""
echo "Generated files:"
echo "  - CLAUDE.md"
echo "  - .claude/commands/project/ ($(ls "$COMMANDS_DEST" | wc -l | tr -d ' ') commands)"
echo ""
echo "Next steps:"
echo "  1. docs/INPUT.md に要件を記載"
echo "  2. /project:requirements で要件定義を開始"
echo "========================================="
