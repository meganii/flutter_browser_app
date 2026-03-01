# Comoreby

Flutter で作成した、Cosense（旧 Scrapbox）専用ブラウザです。  
このリポジトリは `flutter_inappwebview` をベースに、Cosense での日常編集をしやすくするための専用 UI と操作を追加しています。

## 目的
- Cosense をモバイルで快適に閲覧・編集する
- 通常ブラウザ機能よりも、Cosense 操作に必要な導線を優先する

## 現在の主な機能
- タブ管理（通常タブ/シークレットタブ）
- `scrapbox.io` を中心にしたナビゲーション制御
- Cosense 編集向けショートカット呼び出し（`comoreby*` JavaScript）
- プロジェクトルートへ戻るホーム操作
- セッション復元（タブ/設定などの保存・復元）
- WebView 詳細設定（Cross-Platform / Android / iOS）

## 専用化ポリシー
- 既定ホームは `https://scrapbox.io/`
- 設定上のサービスは Cosense 固定

## 開発
```bash
flutter pub get
flutter run
```

## テスト
```bash
flutter test
```
