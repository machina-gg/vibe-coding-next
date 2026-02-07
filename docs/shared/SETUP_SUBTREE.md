# Subtree セットアップガイド

vibe-coding-utils をプロジェクトに取り込むための手順です。

---

## 1. subtree で取り込む

```bash
# プロジェクトのルートディレクトリで実行
git subtree add --prefix=.claude/vibe-coding-utils https://github.com/machina-gg/vibe-coding-utils.git develop --squash
```

これにより `.claude/vibe-coding-utils/` 配下にテンプレートが配置されます。

---

## 2. フレームワークを選択してセットアップ

```bash
# Next.js の場合
bash .claude/vibe-coding-utils/scripts/setup-framework.sh nextjs

# Chrome拡張の場合
bash .claude/vibe-coding-utils/scripts/setup-framework.sh chrome-extension
```

このスクリプトは以下を行います：

1. `.claude/commands/project/` にコマンドファイルをコピー
2. `CLAUDE.md` を生成（共通ルール + フレームワーク固有設定を結合）

---

## 3. 更新方法

テンプレートが更新された場合、以下で最新版を取り込めます：

```bash
# 最新版を取得
git subtree pull --prefix=.claude/vibe-coding-utils https://github.com/machina-gg/vibe-coding-utils.git develop --squash

# セットアップを再実行（コマンドとCLAUDE.mdを再生成）
bash .claude/vibe-coding-utils/scripts/setup-framework.sh nextjs
```

---

## 4. ディレクトリ構成

取り込み後のプロジェクト構成：

```
your-project/
├── .claude/
│   ├── vibe-coding-utils/    # subtree で取り込んだテンプレート（編集しない）
│   │   ├── templates/
│   │   ├── commands/
│   │   ├── docs/
│   │   └── scripts/
│   └── commands/
│       └── project/          # setup-framework.sh で生成されたコマンド
├── CLAUDE.md                 # setup-framework.sh で生成された指示書
├── docs/                     # プロジェクト固有のドキュメント
└── src/                      # ソースコード
```

---

## 注意事項

- `.claude/vibe-coding-utils/` 内のファイルは直接編集しない（subtree pull で上書きされるため）
- カスタマイズが必要な場合は、生成された `CLAUDE.md` を直接編集する
- `.claude/commands/project/` は `.gitignore` に追加済み（生成ファイルのため）
