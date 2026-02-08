---
description: 実装を行う（vibe-coding-utils リポジトリ用）
---

以下の手順で本実装を行ってください：

## 引数

- Issue番号（必須）: 単一または複数指定可能
  - 単一: `30`
  - 複数: `30,31,32` または `30 31 32`
- **Issue番号が指定されていない場合は実行しない。以下を案内：**
  「Issue番号を指定してください。例: `/project:implement 30`
  Open な Issue 一覧は GitHub Issues で確認できます。」

## 実装フロー

以下のフローを Issue ごとに実行する。複数 Issue の場合は Task ツールで並列実行する。

### 1. worktree で作業ディレクトリを作成

```bash
git fetch origin
git worktree add ../vibe-coding-utils-XX -b feature/#XX origin/develop
```

### 2. GitHub Issue の内容を確認

- 指定された Issue 番号の内容を取得・確認する

### 3. コード実装

- 対象ファイル（テンプレート、コマンド、スクリプト、ドキュメント等）を修正・追加
- 既存のファイル構成・命名規則に従う

### 4. コミット・プッシュ・PR作成

- `git -C ../vibe-coding-utils-XX` でコマンドを実行する
- コミットメッセージに `Closes #XX` を含める
- PR を develop ブランチに向けて作成する

### 5. GHA CI 結果を確認

```bash
gh pr checks <PR番号> --watch
```

- **成功**: 次のステップへ
- **失敗**: エラー内容を確認し、修正してプッシュ → 再度CIを待つ

### 6. 完了

- worktree はこのタイミングでは削除しない（CI失敗時の追加修正に備える）
- マージ後のクリーンアップは `/project:cleanup` で一括実行する

## コミットメッセージ規則

- `Closes #XX` をメッセージに含める（PRマージ時にIssue自動クローズ）
- 1コミット1Issueを基本とする
