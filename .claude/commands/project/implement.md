---
description: 実装を行う
---

以下の手順で本実装を行ってください：

## 引数

- Issue番号（必須）: 単一または複数指定可能
  - 単一: `30`
  - 複数: `30,31,32` または `30 31 32`

## 実装フロー（単一・複数共通）

1. worktree で作業ディレクトリを作成
   ```bash
   git fetch origin
   git worktree add ../プロジェクト名-XX -b feature/#XX origin/develop
   ```
2. 依存パッケージのインストール（package.json が存在する場合）
   ```bash
   cd ../プロジェクト名-XX
   npm install
   ```
3. 実装（lint / format / テスト）
4. コミット・プッシュ・PR作成
   - コミットメッセージに `Closes #XX` を含める
   - PR は常に作成する
5. worktree を削除
   ```bash
   cd ../プロジェクト名
   git worktree remove ../プロジェクト名-XX
   ```

### 複数Issue の場合

上記フローを Task ツールで並列実行する。

### コミットメッセージ規則

- `Closes #XX` をメッセージに含める（PRマージ時にIssue自動クローズ）
- 1コミット1Issueを基本とする

## 注意事項

- worktree作成前に `git fetch origin` で最新化すること
- 各worktreeで `npm install` が必要（package.json が存在する場合）

---

## 前提条件の確認

1. プロトタイプ確認
   - `/project:prototype` が完了していること
   - デザインがユーザーに承認されていること
   - 未完了の場合は先に `/project:prototype` を実行

2. テスト設計確認
   - `/project:test-design` が完了していること
   - docs/TEST_CASES.md が存在すること
   - 未完了の場合は先に `/project:test-design` を実行

3. src/ が存在しない場合 → CLAUDE.md の「環境構築手順」を実行

## 実装手順

4. GitHub Issue を確認してタスク取得
   - Open な Issue から優先度の高いものを選択
   - 該当 Issue がなければユーザーに確認

5. コード実装
   - CLAUDE.md のコーディング規約に従う
   - ディレクトリ構成・命名規則を守る
   - プロトタイプで作成したコンポーネントを活用

6. UIコンポーネントの場合
   - Storybook に stories を追加

7. **E2Eテスト実装**
   - docs/TEST_CASES.md を参照
   - 実装した機能に対応するテストケースを実装
   - テストファイルは `e2e/` ディレクトリに作成
   - テスト実行: `npm run test:e2e`
   - TEST_CASES.md のステータスを「実装済」に更新

8. lint / format 実行
   - npm run format
   - npm run lint

9. テスト実行
   - npm run test（Vitest で単体テスト）
   - npm run test:e2e（Playwright でE2Eテスト）

10. **ドキュメント更新（該当する場合）**
    - データモデル変更 → docs/DATA_MODEL.md を更新
    - 新規コンポーネント追加 → docs/COMPONENT.md を更新
    - 画面追加・変更 → docs/SCREEN.md を更新

11. 実装完了したらコミット・push
    - コミットメッセージに `Closes #XX` を含める
    - 例: `Prettier設定を変更 Closes #34`
    - PR を作成する
    - PRマージ時にIssueが自動クローズされる
