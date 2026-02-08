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

# プロジェクトルートを特定（submodule の場合は .claude/vibe-coding-utils/ の2つ上）
# スクリプトが直接実行される場合と submodule 経由の場合の両方に対応
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

# 1. コマンドディレクトリの作成（古いファイルをクリアして再作成）
COMMANDS_DEST="$PROJECT_ROOT/.claude/commands/project"
rm -rf "$COMMANDS_DEST"
mkdir -p "$COMMANDS_DEST"

# 2. shared コマンドをコピー
echo "[1/5] Copying shared commands..."
for file in "$BASE_DIR/commands/shared/"*.md; do
  if [ -f "$file" ]; then
    cp "$file" "$COMMANDS_DEST/"
    echo "  -> $(basename "$file")"
  fi
done

# 3. フレームワーク固有コマンドをコピー
echo "[2/5] Copying $FRAMEWORK commands..."
for file in "$BASE_DIR/commands/$FRAMEWORK/"*.md; do
  if [ -f "$file" ]; then
    cp "$file" "$COMMANDS_DEST/"
    echo "  -> $(basename "$file")"
  fi
done

# 4. CLAUDE.md を生成（BASE + フレームワーク固有を結合）
echo "[3/6] Generating CLAUDE.md..."
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

cat "$BASE_DIR/templates/CLAUDE_BASE.md" > "$CLAUDE_MD"
echo "" >> "$CLAUDE_MD"
cat "$BASE_DIR/templates/$CLAUDE_TEMPLATE" >> "$CLAUDE_MD"

echo "  -> CLAUDE.md generated"

# 5. CLAUDE_CODE_REFERENCE.md をコピー
echo "[4/6] Copying CLAUDE_CODE_REFERENCE.md..."
cp "$BASE_DIR/CLAUDE_CODE_REFERENCE.md" "$PROJECT_ROOT/CLAUDE_CODE_REFERENCE.md"
echo "  -> CLAUDE_CODE_REFERENCE.md copied"

# 6. docs/INPUT.md をコピー（存在しない場合のみ）
echo "[5/6] Setting up project files..."
DOCS_DIR="$PROJECT_ROOT/docs"
mkdir -p "$DOCS_DIR"

if [ ! -f "$DOCS_DIR/INPUT.md" ]; then
  cp "$BASE_DIR/templates/INPUT.md" "$DOCS_DIR/INPUT.md"
  echo "  -> docs/INPUT.md created"
else
  echo "  -> docs/INPUT.md already exists, skipping"
fi

# 6. settings.local.json を生成（存在しない場合のみ）
echo "[6/6] Generating settings.local.json..."
SETTINGS_LOCAL="$PROJECT_ROOT/.claude/settings.local.json"

# フレームワーク別のパッケージマネージャ許可
case "$FRAMEWORK" in
  nextjs)
    PKG_MANAGER_PERMISSION='"Bash(npm *)"'
    ;;
  chrome-extension)
    PKG_MANAGER_PERMISSION='"Bash(pnpm *)"'
    ;;
esac

if [ ! -f "$SETTINGS_LOCAL" ]; then
  mkdir -p "$(dirname "$SETTINGS_LOCAL")"
  cat > "$SETTINGS_LOCAL" << SETTINGS_EOF
{
  "permissions": {
    "allow": [
      "WebSearch",
      ${PKG_MANAGER_PERMISSION},
      "Bash(npx *)",
      "Bash(git add *)",
      "Bash(git branch *)",
      "Bash(git checkout *)",
      "Bash(git commit *)",
      "Bash(git diff *)",
      "Bash(git diff)",
      "Bash(git fetch *)",
      "Bash(git fetch)",
      "Bash(git log *)",
      "Bash(git pull *)",
      "Bash(git push *)",
      "Bash(git push)",
      "Bash(git restore *)",
      "Bash(git rm *)",
      "Bash(git stash *)",
      "Bash(git stash)",
      "Bash(git status *)",
      "Bash(git status)",
      "Bash(git submodule *)",
      "Bash(git worktree *)",
      "Bash(gh issue create *)",
      "Bash(gh issue close *)",
      "Bash(gh issue comment *)",
      "Bash(gh issue edit *)",
      "Bash(gh issue list *)",
      "Bash(gh issue view *)",
      "Bash(gh pr checks *)",
      "Bash(gh pr comment *)",
      "Bash(gh pr create *)",
      "Bash(gh pr edit *)",
      "Bash(gh pr view *)",
      "Bash(gh run view *)",
      "Bash(gh api *)",
      "Bash(bash .claude/vibe-coding-utils/*)",
      "Bash(ls *)",
      "Bash(mkdir -p src/*)",
      "Bash(tree *)",
      "Bash(find *)"
    ]
  }
}
SETTINGS_EOF
  echo "  -> settings.local.json created"
else
  echo "  -> settings.local.json already exists, skipping"
fi

# 8. .gitignore に生成ファイルの除外パターンを追加（各行ごとに重複チェック）
GITIGNORE="$PROJECT_ROOT/.gitignore"
GITIGNORE_ENTRIES=(
  ".claude/commands/project/"
  ".claude/tmp/"
  "CLAUDE.md"
  "CLAUDE_CODE_REFERENCE.md"
)
GITIGNORE_UPDATED=false
for entry in "${GITIGNORE_ENTRIES[@]}"; do
  if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
    if [ "$GITIGNORE_UPDATED" = false ]; then
      echo "" >> "$GITIGNORE"
      echo "# Generated by vibe-coding-utils (setup-framework.sh)" >> "$GITIGNORE"
      GITIGNORE_UPDATED=true
    fi
    echo "$entry" >> "$GITIGNORE"
  fi
done
if [ "$GITIGNORE_UPDATED" = true ]; then
  echo "  -> .gitignore updated"
fi

# 9. .prettierignore に生成ファイルの除外パターンを追加（各行ごとに重複チェック）
PRETTIERIGNORE="$PROJECT_ROOT/.prettierignore"
PRETTIERIGNORE_ENTRIES=(
  "CLAUDE.md"
  "CLAUDE_CODE_REFERENCE.md"
  ".claude/commands/project/"
  ".claude/vibe-coding-utils/"
)
PRETTIERIGNORE_UPDATED=false
for entry in "${PRETTIERIGNORE_ENTRIES[@]}"; do
  if ! grep -qF "$entry" "$PRETTIERIGNORE" 2>/dev/null; then
    if [ "$PRETTIERIGNORE_UPDATED" = false ]; then
      echo "" >> "$PRETTIERIGNORE"
      echo "# Generated by vibe-coding-utils (setup-framework.sh)" >> "$PRETTIERIGNORE"
      PRETTIERIGNORE_UPDATED=true
    fi
    echo "$entry" >> "$PRETTIERIGNORE"
  fi
done
if [ "$PRETTIERIGNORE_UPDATED" = true ]; then
  echo "  -> .prettierignore updated"
fi

echo ""
echo "========================================="
echo "Setup complete!"
echo ""
echo "Generated files:"
echo "  - CLAUDE.md"
echo "  - CLAUDE_CODE_REFERENCE.md"
echo "  - .claude/commands/project/ ($(ls "$COMMANDS_DEST" | wc -l | tr -d ' ') commands)"
echo "  - docs/INPUT.md"
echo ""
echo "Next steps:"
echo "  1. docs/INPUT.md に要件を記載"
echo "  2. /project:requirements で要件定義を開始"
echo ""
echo "操作リファレンス: CLAUDE_CODE_REFERENCE.md"
echo "========================================="
