# Daily Command — PvP マッチング設計書 v2.0

**作成日**: 2026-07-02
**対象バージョン**: v2.0
**前提**: Firebase 本設定完了後に着手（現状 Firebase 未接続）

---

## 1. Vision

```
「今日の敵司令官」に加えて「今日のライバルプレイヤー」を用意する。
CPU戦で鍛えたデッキを、同格の相手にぶつける緊張感がリテンションを底上げする。
```

**既存 CPU 戦（v1.0）との違い**:
- CPU戦 = 毎日ネタが変わる「予測可能な挑戦」（AI司令官3パターン固定ロジック）
- PvP戦 = 予測不能な「対人の緊張感」（相手も同じ2分・同じルールで挑む）

---

## 2. なぜ今のアーキテクチャのままでは作れないか

v1.0 の StageScreen は完全にクライアント側でダメージ計算している（`_attack()` 内で `enemyHP -= totalDamage` を直接書き換え）。これを PvP にそのまま使うと：

- **不正が容易**: クライアントの `enemyHP` 変数をローカルで自由に書き換えられる
- **同期不能**: 相手の画面と自分の画面で結果がズレる可能性がある

→ **PvP はサーバー（Cloud Functions）を判定の権威（authoritative）にする必要がある。**
CPU戦はこれまで通りクライアント計算のままで良い（変更不要）。

---

## 3. 対戦モデルの選択

即時リアルタイム同期（WebSocket的な逐次同期）は実装・運用コストが高い。個人開発の運用体制を踏まえ、以下を採用する。

### 採用: 非同期ターン制「配置バトル」方式

```
1. プレイヤーA: デッキ配置を決めて「対戦成立」をリクエスト
2. マッチメイキングでプレイヤーBの直近配置データとマッチング
   （Bはリアルタイムで参加していなくてもよい = 幽霊対戦ではなく
    「直近に登録された配置のスナップショット」を使う早期実装）
3. Cloud Functions が両者の配置・ユニットステータスから
   決定論的にシミュレーションを実行 → 勝敗を1回で確定
4. 両プレイヤーに結果をプッシュ通知 / 次回起動時に結果表示
```

**メリット**:
- WebSocket 不要、Firestore の read/write と Cloud Functions だけで完結
- 相手がオフラインでもマッチング可能（対戦相手が見つからず離脱するのを防ぐ）
- 既存の「2分間タップ連打」ではなく「配置を決めたら自動再生」に変える必要があるが、
  これはむしろ CPU 戦との差別化になる（PvPは頭脳戦、CPU戦は反射神経寄り）

**この案の欠点（Won't/v2.1 送りとして明記）**:
- 真のリアルタイム対戦ではない（「ゴースト対戦」的な体験）
- 元設計書の Won't 項目「ゴースト対戦（自分の過去配置）」と類似するため、
  ユーザーへの見せ方は「AIがあなたの代わりに戦う」ではなく
  「非同期タクティクスバトル」という新しい体験として明確に演出すること

---

## 4. データモデル（Firestore Schema 追加分）

```yaml
# Collection: pvpQueue
# マッチメイキング待機列
pvpQueue/
  {userId}/
    deckSnapshot: array      # 対戦時点のデッキ・ユニットステータスのスナップショット
      - unitId: string
      - unitType: string
      - level: int
      - equipped: map
    playerLevel: int
    queuedAt: timestamp
    status: string            # "waiting" | "matched" | "expired"

# Collection: pvpMatches
# 対戦結果記録
pvpMatches/
  {matchId}/
    playerA: {userId, displayName, deckSnapshot}
    playerB: {userId, displayName, deckSnapshot}
    winnerId: string
    battleLog: array           # シミュレーション結果のターン毎ログ（リプレイ用）
      - turn: int
      - actorId: string
      - damage: int
      - hpAfter: {playerA: int, playerB: int}
    createdAt: timestamp
    seasonId: string           # シーズン制ランキング用

# Collection: pvpRankings
# レーティング（ELO風）
pvpRankings/
  {userId}/
    rating: int                 # 初期値 1200
    wins: int
    losses: int
    winStreak: int
    seasonId: string
    updatedAt: timestamp
```

---

## 5. マッチメイキングロジック（Cloud Functions）

```
トリガー: pvpQueue に新規ドキュメント作成時 (onCreate)

1. 自分のレーティング ±150 の範囲で pvpQueue を検索
2. 見つかった場合:
   a. 両者のデッキで決定論的バトルシミュレーションを実行
      （CPU戦の難度スケーリングロジックを流用可能）
   b. pvpMatches に結果を書き込み
   c. pvpQueue の両ドキュメントを status: "matched" に更新
   d. pvpRankings のレーティングを ELO 式で更新
      新レーティング = 現レーティング + K × (実際の勝敗 - 期待勝率)
      K = 32（初心者帯）/ 16（上級者帯 rating > 1800）
3. 見つからない場合:
   a. 5分間 CPU 戦の「今日の司令官」ロジックを流用した
      擬似対戦相手（Bot）とマッチングし、"CPU代行" フラグを立てる
      → 対戦相手が本当に見つからず離脱する事故を防ぐ（Cold Start対策）
```

**Cold Start 対策が重要な理由**: 個人開発規模だと同接ユーザーが少なく、
「マッチングされない」体験が一番ユーザーを失う。Botフォールバックは必須。

---

## 6. UI / 画面構成（新規4画面）

```
┌─────────────────────────────────────┐
│ PvP ホーム画面                        │
│  ├─ 現在のレート・ランク表示           │
│  ├─ [対戦する] ボタン（マッチング開始） │
│  └─ シーズン残り期間表示               │
├─────────────────────────────────────┤
│ マッチング中画面                       │
│  ├─ 検索アニメーション（〜5秒演出）     │
│  └─ [キャンセル]                      │
├─────────────────────────────────────┤
│ PvP バトル結果画面                     │
│  ├─ 対戦相手情報（名前・デッキ）        │
│  ├─ ターン毎リプレイ（簡易アニメ）      │
│  ├─ 勝敗 + レート増減表示              │
│  └─ [シェア] [もう一度対戦]            │
├─────────────────────────────────────┤
│ PvP ランキング画面                     │
│  ├─ シーズンランキング Top 100         │
│  └─ 既存 LeaderboardScreen と統合可能  │
└─────────────────────────────────────┘
```

既存のリッチUIウィジェット（GlowButton / GlassPanel / RadialBurst / DamagePopup）を
そのまま流用してビジュアル統一する。

---

## 7. KPI 計測（既存5個に追加）

```
pvp_match_started    — マッチング開始
pvp_match_found      — マッチ成立（CPU代行かどうかのフラグ付き）
pvp_match_completed  — 対戦結果確定（win/lose, rating_change）
pvp_rank_up          — ランク帯昇格（Bronze→Silver等）
```

---

## 8. 実装フェーズ（推定工数）

```
Phase 1: データモデル + Cloud Functions マッチングロジック    [8-10h]
  - pvpQueue / pvpMatches / pvpRankings スキーマ実装
  - 決定論的バトルシミュレーション関数（CPU戦ロジック流用）
  - ELO レーティング計算

Phase 2: Bot フォールバック（Cold Start対策）                [3-4h]
  - 5分未マッチ時の代替処理
  - 「今日の司令官」ロジックの再利用

Phase 3: クライアント UI 実装                                [6-8h]
  - PvPホーム / マッチング中 / 結果 / ランキング 4画面
  - 既存リッチウィジェット流用

Phase 4: リプレイ演出                                        [4-5h]
  - battleLog を StageScreen の演出（シェイク/ポップアップ/HPバー）で再生

Phase 5: テスト + シーズン制運用設計                          [4-5h]
  - シーズン切り替えバッチ処理（Cloud Scheduler）
  - 不正防止テスト（クライアント改竄が結果に影響しないことを確認）

合計: 25-32h（Firebase 本設定完了後に着手）
```

---

## 9. 前提ブロッカー

```
⏸ Firebase 本設定必須（Firestore + Cloud Functions + Cloud Scheduler）
  → 現在 Windows Google Drive パスのシンボリックリンク問題で
    firebase_core 等が pubspec から除外されている
  → 対応: プロジェクトを C:\ 等の英語パスへ移動 or シンボリックリンク回避策の適用後、
    Firebase 本設定スキル（flutter-firebase-setup）で対応
```

---

## ✅ 設計完了チェック

```
□ Vision（CPU戦との差別化）が明確
□ 対戦モデル（非同期配置バトル）を選定、リアルタイムWSは見送り理由を明記
□ データモデル（Firestore schema）定義
□ マッチングロジック（ELO + Cold Start Bot フォールバック）定義
□ UI 4画面を洗い出し、既存ウィジェット流用方針を明記
□ KPI 4個を追加定義
□ 実装フェーズ・工数見積もり完了
□ 前提ブロッカー（Firebase本設定）を明記
→ Firebase 本設定完了後、Phase 1 から実装開始可能
```
