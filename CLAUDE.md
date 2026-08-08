# DailyCommand プロジェクト設定

**プロジェクト**: Daily Command — 日替わりAI司令官の戦略カジュアルゲーム  
**最終更新**: 2026-07-02  
**リポジトリ**: ローカル Git（`G:\マイドライブ\apps\daily_command`）

---

## 📋 クイックリファレンス

### コマンド集
```bash
# 分析
flutter analyze

# 依存更新
flutter pub get
flutter clean && flutter pub get

# ビルド
flutter run -d windows  # Windows（開発中）
flutter run -d android  # Android（本番）
flutter run -d ios      # iOS（本番）

# テスト
flutter test
```

### ホットキー
- `r` — Hot Reload（コード変更）
- `R` — Hot Restart（状態リセット）
- `q` — アプリ終了

---

## 🎯 実装状況（2026-07-02 時点）

### v1.0 Core ✅ 100%
```
✅ 2分ステージシステム + 敵AI難度スケーリング
✅ デッキシステム（モデル定義・Riverpod）
✅ ①日替わりAI司令官（3パターン・EnemyAIEngine）
✅ ②鮮度ユニット（24h FOMO）
✅ ⑤育つ箱庭 + 採掘システム（MiningScreen）
✅ Aha Moment フロー（ステージ1→2→推奨→採掘→再挑戦→クリア）
✅ KPI 計測設計（5イベント・Analytics 記録ロジック）
```

### v1.1 Should 🔄 40%
```
✅ リーダーボード（週間ランク・10ユーザー）
✅ ユニット感情アニメーション（6種類・StageVictory統合）
🔄 QRコード友達招待（優先度：中 / 3-4h）
🔄 箱庭ライティング変化（優先度：低 / 2h）
🔄 スキンシステム（優先度：低 / 4-5h）
```

---

## 📁 ファイル構成

```
daily_command/
├── lib/
│   ├── main.dart
│   ├── models/              — データモデル（Unit / Stage / Commander / Mining / Leaderboard）
│   ├── services/            — Firebase 統合予定（Analytics / Auth）
│   ├── viewmodels/          — Riverpod StateProvider（全状態管理）
│   ├── views/               — UI 画面（10個実装済み）
│   ├── widgets/             — 再利用可能ウィジェット
│   └── utils/               — 定数・ヘルパー
├── pubspec.yaml             — 依存定義
├── FEATURE_ROADMAP.md       — 全機能・コンテンツリスト
├── CLAUDE.md                — 本ファイル
└── .gitignore
```

### 主要ファイル（参照順）

| ファイル | 内容 | 行数 |
|---------|------|------|
| `lib/models/` | Unit/Stage/Commander/Mining/Leaderboard | 600+ |
| `lib/viewmodels/` | StateProvider & AI エンジン | 400+ |
| `lib/views/stage_screen.dart` | 2分戦闘メイン画面 | 250+ |
| `lib/views/leaderboard_screen.dart` | 週間ランキング | 180+ |
| `lib/widgets/unit_emotion_display.dart` | 感情アニメーション | 140 |
| `FEATURE_ROADMAP.md` | 完全機能リスト | 600+ |

---

## 🔧 技術スタック（確定）

**言語 / フレームワーク**
- Dart 3.x + Flutter （最新安定版）
- Architecture: MVVM（Riverpod StateProvider）

**状態管理**
- Riverpod v3.3.2 （StateProvider ベース）
- state_notifier v1.0.0
- 軽量化・キャッシュ不要（ローカル状態のみ）

**ローカルストレージ**
- Hive v2.x （キャッシュ・後で実装）

**アニメーション**
- Flutter built-in （Lottie 不使用・パフォーマンス優先）

**計測 / 分析（未統合）**
- Firebase Analytics v12.4.3
- Firebase Crashlytics v5.2.4
- Remote Config （キー 5個定義済み）

**課金（未統合）**
- RevenueCat （SDK 待ち）
- Google Play Billing / App Store

**デザイン**
- カラーパレット 5色定義済み（ColorPalette.dart）
- マテリアルデザイン 3（Material3）
- ダークテーマ デフォルト

---

## ⚠️ 既知の制限 / Todo

### Windows ビルド制限
```
❌ firebase_*: シンボリックリンク エラー（ドライブ間の問題）
   → iOS/Android ビルドを優先
   → Firebase 本番設定時に C ドライブに移動予定
```

### 計測未統合
```
🔄 Firebase Analytics — 記録ロジック実装済み / 接続待ち
🔄 Remote Config — キー定義済み / 接続待ち
🔄 Crashlytics — 定義済み / 接続待ち
```

### 未実装の UI / 機能
```
🔄 デッキ編集画面（モデル定義済み）
🔄 ユニット詳細画面（ユニット図鑑）
🔄  箱庭画面（採掘スクリーン統合予定）
🔄 プロフィール / 設定
```

---

## 📊 ビルド設定

### iOS
```yaml
platform: iOS 14+
deployment_target: 14.0
provisioning_profile: （手動設定待ち）
```

### Android
```yaml
minSdkVersion: 21
targetSdkVersion: 33
```

---

## 🚀 次のステップ（優先順）

1. **v1.1 残り 3機能** — 2026-07-16 締切
   - QRコード友達招待（準備: qr_flutter パッケージ）
   - 箱庭ライティング変化（時間帯判定）
   - スキンシステム（UI / 課金フロー）

2. **Firebase 本番設定** — 2026-07-20 締切
   - google-services.json / GoogleService-Info.plist 追加
   - プロジェクト C ドライブに移動
   - iOS/Android ビルド テスト

3. **テストフライト / 内部テスト** — 2026-07-25

4. **バグ修正 + UX 改善** — 2026-08-01

5. **v1.0 リリース** — 2026-08-15（目標）

---

## 📞 サポート情報

### 設計ドキュメント
- **完全設計書**: `G:\マイドライブ\design\DailyCommand\game-dailycommand-design-v1_0.md`
- **機能ロードマップ**: `FEATURE_ROADMAP.md` ← 全機能リスト

### メモリ / コンテキスト
- **実装進捗**: `~/.claude/projects/G---------apps/memory/project_daily_command_v1_1.md`
- **過去の落とし穴**: `~/.claude/projects/G---------apps/memory/design_lessons_pattern_library.md`

---

## ✅ チェックリスト（次回セッション）

- [ ] FEATURE_ROADMAP.md を確認（全機能リスト）
- [ ] v1.1 残り 3機能の優先順確認
- [ ] Firebase 設定ファイル取得
- [ ] iOS/Android ビルド テスト準備
- [ ] Remote Config 値の A/B テスト設定

---

**Last Update**: 2026-07-02 19:00 JST  
**Next Review**: 2026-07-09
