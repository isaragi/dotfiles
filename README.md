# dotfiles

個人の開発環境設定を置いています。ディレクトリごとに独立しているので、必要なものだけ持っていってください。

## claude/ — Claude Code のステータスライン

`claude/statusline.sh` は Claude Code の画面下部に次の情報を表示するスクリプトです。

- モデル名
- 現在のディレクトリ（`~` 短縮表記）
- git ブランチ。zsh の vcs_info と同じく、staged があれば黄色の `!`、unstaged があれば赤の `+` を付ける
- 追加・削除した行数
- コンテキストウィンドウの使用量と使用率（70% 以上で黄、90% 以上で赤）
- セッションのコスト（USD）

必要なもの: `jq`

### 導入

```bash
cp claude/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

`~/.claude/settings.json` に `claude/settings.snippet.json` の内容を追記します。

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

## ghostty/ — Ghostty の設定

`ghostty/config` は [Ghostty](https://ghostty.org/) の設定です。テーマは TokyoNight、フォントは PlemolJP35 Console NF を使っています。

### 導入

```bash
mkdir -p ~/.config/ghostty
cp ghostty/config ~/.config/ghostty/config
```
