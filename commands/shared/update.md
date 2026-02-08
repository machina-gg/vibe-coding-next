---
description: vibe-coding-utils を最新化する
---

以下の手順で vibe-coding-utils サブモジュールを最新化し、コマンドと CLAUDE.md を再生成してください：

## 1. feature ブランチの作成

```bash
git fetch origin
git checkout -b chore/update-vibe-coding-utils origin/develop
```

## 2. サブモジュールの更新

```bash
git submodule update --remote .claude/vibe-coding-utils
```

## 3. 更新内容の確認

更新前後のコミット差分をユーザーに表示する：

```bash
git diff --submodule .claude/vibe-coding-utils
```

更新がない場合は「すでに最新です」と報告して終了（ブランチも削除する）。

## 4. フレームワークの判定

CLAUDE.md の技術スタックセクションからフレームワークを判定する：

- `Plasmo` → `chrome-extension`
- `Next.js` → `nextjs`

## 5. セットアップスクリプトの再実行

```bash
bash .claude/vibe-coding-utils/scripts/setup-framework.sh <framework>
```

## 6. 差分の確認

再生成されたファイルの差分を確認する：

```bash
git diff
```

変更内容をユーザーに報告する。

> **注意**: 生成ファイルが `.gitignore` に含まれている場合、サブモジュール参照の変更のみがコミット対象になる。

## 7. コミット・プッシュ

変更をコミットしてプッシュする：

- サブモジュールの更新と再生成ファイルをまとめて1コミット
- コミットメッセージ例: `chore: vibe-coding-utilsを最新化`

```bash
git add .
git commit -m "chore: vibe-coding-utilsを最新化"
git push -u origin chore/update-vibe-coding-utils
```

## 8. PR 作成

develop ブランチに向けて PR を作成する：

```bash
gh pr create --base develop --title "chore: vibe-coding-utilsを最新化" --body "サブモジュールを最新化し、コマンドとCLAUDE.mdを再生成"
```

## 9. GHA CI 結果を確認

```bash
gh pr checks <PR番号> --watch
```

- **成功**: 完了
- **失敗**: エラー内容を確認し、修正してプッシュ → 再度CIを待つ
