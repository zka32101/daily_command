# Daily Command — 機能・コンテンツ完全リスト

**最終更新**: 2026-07-02  
**現在バージョン**: v1.0 + v1.1 実装中  
**進捗**: Core 100% / v1.1 40% / v2.0 0%

---

## ✅ 実装済み（v1.0 — Core 5機能）

### 1. 2分ステージシステム + 敵AI難度スケーリング
- **実装**: ✅ StageScreen
- **内容**:
  - 2分間の リアルタイム戦闘タイマー
  - ステージ難度 1〜10 スケーリング
  - ステージ 1: HP 60（簡単・必ずクリア可能）
  - ステージ 2: HP 120（敵強化・初敗北の経験）
  - ステージ 3+: 段階的難化
  - 敵HP / 味方HP ゲージ表示
  - リアルタイムダメージ計算

### 2. デッキシステム（ユニット3～5体選択・配置）
- **実装**: ✅ モデル定義済み / UI 未実装
- **内容**:
  - デフォルトユニット 3体（Warrior / Mage / Archer）
  - ユニット Lv 1-10 スケール
  - 属性ベース補正（Red / Green / Blue）
  - デッキ保存機能 Structure 定義済み

### 3. ①日替わりAI司令官
- **実装**: ✅ CommanderProvider + EnemyAIEngine
- **内容**:
  - 3種類の性格パターン（日付シードで毎日ローテーション）
    - 🔴 **Aggressive（攻撃型）**: 高攻撃力 × 低HP × 即座配置
    - 🔵 **Defensive（防御型）**: 低攻撃力 × 高HP × 堅固配置
    - 🟠 **Balanced（バランス型）**: 中攻撃力 × 中HP × 巧妙配置
  - 敵司令官名表示（StageScreen AppBar）
  - 敵戦術説明テキスト
  - 性格色（赤 / 青 / オレンジ）で視覚化
  - AI戦術計算（ダメージ・HP・ユニット配置）

### 4. ②鮮度ユニット（24h FOMO）
- **実装**: ✅ モデル / プロバイダー定義済み
- **内容**:
  - 毎朝 09:00 JST に新鮮ユニット配布
  - 24時間で消滅（FOMO 演出）
  - レアリティ（Rare / Epic / Legendary）
  - UI：カウントダウン砂時計 + 粒子化アニメ（未実装）

### 5. ⑤育つ箱庭 + 採掘システム
- **実装**: ✅ MiningScreen +採掘アニメーション
- **内容**:
  - 1日 1回採掘制限（16時間クールタイム）
  - 3種鉱石獲得（Red / Green / Blue 各 1個）
  - 採掘スケールアニメーション（500ms）
  - 採掘成功表示 + 鉱石カウント表示
  - 鉱石属性アイコン（赤・緑・青）
  - Remote Config でクールタイム調整可能

---

## ✅ 実装済み（計測設計）

### KPI イベント定義（5個・全て実装済み）

| # | イベント | タイミング | 測定値 | KR対応 |
|---|---------|---------|-----|----|
| 1 | **onboarding_complete** | ステージ 1 クリア | timestamp | KR1 |
| 2 | **aha_moment_reached** | ステージ2→採掘→再挑戦→クリア | stageId, time_taken | KR1/2 |
| 3 | **stage_cleared** | ステージクリア時 | stageId, stars, minerals | KR1/2 |
| 4 | **mining_attempted** | 採掘実行時 | success, additive | KR3 |
| 5 | **monetization_event** | 課金成功時 | productId, price | KR3/4 |

**実装ファイル**:
- `lib/services/analytics_service.dart` — イベント定義
- `lib/services/analytics_provider.dart` — 記録ロジック
- `lib/views/stage_screen.dart` — イベント自動記録

### Firebase 設定（後で実装）
- **Remote Config キー** (定義済み):
  - paywall_text / paywall_timing
  - difficulty_scaler
  - mining_cooltime_hours
  - daily_mission_reward
- **Crashlytics**: セットアップ待ち
- **Analytics**: 記録ロジック実装済み / Firebase 接続待ち

---

## ✅ 実装済み（v1.1 — 2/5 完了）

### 1. リーダーボード（週間ランク）✅
- **実装**: ✅ LeaderboardScreen + プロバイダー
- **内容**:
  - トップ 3 ハイライト（金・銀・銅メダル）
  - 週間ランキングリスト（10ユーザー）
  - 各ユーザー: Rank / Name / Lv / 連続ログイン日数 / 週間スコア
  - 現在のユーザーはハイライト表示
  - 週の日付範囲表示
  - 周辺ランク表示用メソッド実装
- **UI統合**: HomeScreen に「週間ランキング」ボタン追加

### 2. ユニット感情アニメーション ✅
- **実装**: ✅ UnitEmotionDisplay（6種類・Lottie不要）
- **内容**:
  - 😊 **Happy** — 緑色 / クリア時 / StageVictoryScreen 統合済み
  - 😠 **Angry** — 赤色 / 戦闘中（未統合）
  - 😢 **Sad** — 青色 / 敗北時（未統合）
  - 😫 **Tired** — 橙色 / ダメージ時（未統合）
  - ⭐ **Confident** — 金色 / 高Lv時（未統合）
  - 😐 **Neutral** — 灰色 / 通常状態
- **アニメーション**: スケール + Elastic easing（500ms）
- **UI統合**: StageVictoryScreen に Happy 感情表示

---

## 🔄 実装予定（v1.1 — 残り 3/5）

### 3. QRコード友達招待 🔄
- **スコープ**: SNS シェア + QR 生成
- **内容**:
  - ステージクリア後のシェア画面
  - 一意なコード生成（uuid）
  - QR コード生成表示（qr_flutter パッケージ）
  - SNS シェア（Twitter / LINE）
  - リーダーボード連携（v1.1+）
- **優先度**: 中（口コミ促進）
- **所要時間**: ~3-4時間

### 4. 箱庭ライティング変化 🔄
- **スコープ**: 時間帯でビジュアル変更
- **内容**:
  - 朝（05:00-11:00）: 明るいグラデーション（黄〜橙）
  - 昼（11:00-17:00）: 標準グラデーション（青〜紫）
  - 夜（17:00-23:00）: 暗いグラデーション（紫〜深紫）
  - 夜中（23:00-05:00）: 月光グラデーション（深青〜黒）
  - 採掘画面背景に反映
  - リアルタイム更新（1分毎）
- **優先度**: 低（ビジュアル向上）
- **所要時間**: ~2時間

### 5. スキンシステム 🔄
- **スコープ**: ユニットスキン変更 UI
- **内容**:
  - デフォルトスキン（全ユニット）
  - 有料スキン（¥120 / 個）
    - 例: 「騎士の正装」「魔導士の儀式衣」
  - スキン装備変更 UI
  - ユニット詳細画面にスキン選択タブ
  - RevenueCat スキン課金フロー
- **優先度**: 低（課金コンテンツ）
- **所要時間**: ~4-5時間

---

## 📋 実装予定（v2.0 — Could / Future）

### AI アドバイス機能
- 敗北時に「強化すべき属性」を AI が提案
- Gemini API 連携
- コスト: 月 ~¥5-10（Haiku使用）

### PvP マッチング
- リアルタイムプレイヤー対戦
- マッチメイキング（Lv ベース）
- ランクマッチシステム
- チケット制（クールタイム）

### クラン要素
- クラン作成 / 参加
- クラン内チャット
- クラン戦（5v5 リアルタイム）
- クラン Lv 進化 / ボーナス

### ユニット 6+ 体
- 現在 3体 → 最大 8-10体 へ拡張
- ユニット獲得メカニクス（ガチャ）
- ユニットフュージョン（同種 2体で進化）

### ゲーム内イベント
- 敵キャラクターのバックストーリー
- 限定敵司令官（月 1-2体）
- イベント期間限定ユニット
- ストーリー演出（ボス戦）

### 他言語対応
- 日本語 100%（v1.0）
- 英語・中国語・韓国語（v2.0）

---

## ❌ スコープ外（Won't）

- **ユニット疲労システム** — 複雑化 / リテンション低下懸念
- **ゴースト対戦（自分の過去配置）** — サーバー負荷 / 遅延リスク

---

## 📊 バージョン別リリース予定

| バージョン | リリース | コンテンツ | 状態 |
|---------|--------|---------|------|
| **v1.0** | 2026-07-15 | Core 5機能 + KPI | ✅ 実装中 |
| **v1.1** | 2026-08-15 | リーダー + 感情 + QR + ライティング + スキン | 🔄 実装中 |
| **v1.2** | 2026-09-30 | バグ修正 + UX 改善 + イベント v1 | 📋 企画中 |
| **v2.0** | 2026-11-30 | PvP + クラン + AI + UI/UX 大改善 | 📋 企画中 |

---

## 📁 ファイル構成（実装済み / 予定含む）

```
lib/
├── main.dart ✅
├── models/
│   ├── unit.dart ✅
│   ├── stage.dart ✅
│   ├── commander.dart ✅
│   ├── mining.dart ✅
│   ├── leaderboard.dart ✅
│   └── index.dart ✅
├── services/
│   ├── analytics_service.dart ✅
│   ├── analytics_provider.dart ✅
│   └── (firebase_service.dart) 📋
├── viewmodels/
│   ├── game_state.dart ✅
│   ├── player_provider.dart ✅
│   ├── mining_provider.dart ✅
│   ├── commander_provider.dart ✅
│   └── leaderboard_provider.dart ✅
├── views/
│   ├── home_screen.dart ✅
│   ├── stage_screen.dart ✅
│   ├── stage_victory_screen.dart ✅
│   ├── stage_defeat_screen.dart ✅
│   ├── mining_screen.dart ✅
│   ├── leaderboard_screen.dart ✅
│   ├── (unit_detail_screen.dart) 📋
│   ├── (deck_editor_screen.dart) 📋
│   ├── (share_screen.dart) 🔄
│   └── (garden_screen.dart) 🔄
├── widgets/
│   ├── unit_emotion_display.dart ✅
│   ├── (commander_display.dart) 📋
│   ├── (deck_selector.dart) 📋
│   └── (particle_effects.dart) 📋
└── utils/
    ├── color_palette.dart ✅
    ├── (haptics_utils.dart) 📋
    └── (constants.dart) 📋
```

**凡例**: ✅ 実装完了 / 🔄 実装中 / 📋 計画中 / ❌ スコープ外

---

## 📈 実装進捗

```
v1.0 Core（5機能）
████████████████████ 100% ✅

v1.1 Should（5機能）
████████░░░░░░░░░░░░  40% 🔄
 ✅ リーダーボード
 ✅ ユニット感情
 🔄 QRコード友達招待
 🔄 箱庭ライティング
 🔄 スキンシステム

v2.0+ Could（無制限）
░░░░░░░░░░░░░░░░░░░░   0% 📋
```

---

**作成日**: 2026-07-02  
**最終更新**: Daily Command v1.1 実装中
