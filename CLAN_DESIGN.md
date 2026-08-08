# Daily Command — クラン要素 設計書 v2.0

**作成日**: 2026-07-02
**対象バージョン**: v2.0
**前提**: Firebase 本設定完了後（PvP と同じブロッカー）。PvP実装後に着手が望ましい（クラン戦はPvPのバトルシミュレーションを流用するため）

---

## 1. Vision

```
「今日の司令官」「今日のライバル」に加えて「今日の仲間」を用意する。
一人用ゲームループ（CPU戦）とPvP（対人）の間に、
ソーシャル・協力の要素を挟むことで離脱を防ぐ「三本目の柱」にする。
```

**既存要素との役割分担**:
| 要素 | 頻度 | 相手 | 目的 |
|---|---|---|---|
| CPU戦（v1.0） | 毎日 | AI司令官 | コア体験・育成ループ |
| PvP（v2.0） | 都度 | ランダムな他プレイヤー | 競争・スリル |
| **クラン（v2.0）** | **週次** | **固定した仲間** | **所属感・離脱防止** |

---

## 2. スコープの絞り込み（重要な設計判断）

元の設計ドキュメント（v1.0 game-dailycommand-design）では「Could（v2.0以降・スコープ大）」に
分類されており、フルスペックのクラン機能（チャット・クラン内ランク・大規模イベント等）は
個人開発の運用体制では過大。**v2.0 は「最小の所属感」に絞る。**

### v2.0 で作るもの（Must）
- クラン作成・参加・脱退
- クラン全体の週間貢献度（メンバーの週間スコア合算）
- クランランキング（クラン同士の週間順位）
- クラン内メンバーリスト（アイコン・貢献度のみ、チャットなし）

### v2.0 で作らないもの（Won't・理由付き）
- **クラン内チャット** → モデレーション運用コストが個人開発では不可能
  （不適切投稿の通報・BAN対応が発生する。v2.1以降、絵文字リアクションのみ等に限定して再検討）
- **クラン戦（5v5リアルタイム）** → PvPの非同期方式をクラン戦に応用するには
  「複数人の配置を同時に集計する」複雑さが増す。v2.1で「クラン対抗・個人戦の合計」
  という単純な形に倒して再設計する
- **クランLv進化・ボーナス** → 過剰な経済設計の複雑化。v2.1で貢献度に応じた
  「クランバッジ」程度に留めて再検討

---

## 3. データモデル（Firestore Schema 追加分）

```yaml
# Collection: clans
clans/
  {clanId}/
    name: string
    description: string
    iconEmoji: string          # スキンと同様、画像アセット不要でコスト削減
    leaderId: string
    memberCount: int            # 上限 20人（運用しやすい規模に制限）
    maxMembers: int              # デフォルト 20
    weeklyContribution: int      # メンバー週間スコアの合算（自動集計）
    createdAt: timestamp
    isPublic: bool               # true: 誰でも参加可 / false: 承認制

    # Sub-collection: members
    members/
      {userId}/
        displayName: string
        role: string             # "leader" | "member"
        weeklyContribution: int   # このメンバー個人の週間貢献
        joinedAt: timestamp

# Collection: clanRankings
# 週次でクラン同士のランキングを記録（アーカイブ用）
clanRankings/
  {weekId}/
    rankings: array
      - clanId: string
        clanName: string
        totalContribution: int
        rank: int
```

**設計判断: `weeklyContribution` は何をカウントするか**
既存の `stage_cleared` KPI イベントの `mineralEarned` 合計をそのままクラン貢献度に転用する。
新しい計測ロジックを作らず、既存イベントの集計方法を変えるだけで実装コストを抑える。

---

## 4. 集計ロジック（Cloud Functions）

```
トリガー: stage_cleared イベント発生時（既存のAnalyticsイベントをトリガーに転用）

1. ユーザーの所属クランを取得
2. clans/{clanId}/members/{userId}.weeklyContribution += mineralEarned
3. clans/{clanId}.weeklyContribution += mineralEarned
   （Firestore トランザクションで整合性を保証）

トリガー: 毎週月曜 00:00（Cloud Scheduler）
1. 全クランの weeklyContribution でソート
2. clanRankings/{weekId} にスナップショット保存
3. 全クランの weeklyContribution / 全メンバーの weeklyContribution を 0 にリセット
```

---

## 5. UI / 画面構成（新規4画面）

```
┌─────────────────────────────────────┐
│ クランホーム画面（未所属時）           │
│  ├─ [クランを作る]                    │
│  ├─ [クランを探す]（検索・おすすめ表示） │
│  └─ クラン説明バナー                   │
├─────────────────────────────────────┤
│ クラン詳細画面（所属時）               │
│  ├─ クラン名・アイコン・メンバー数     │
│  ├─ 週間貢献度（クラン全体）           │
│  ├─ メンバーリスト（貢献度順ソート）    │
│  └─ [脱退]（リーダーは委譲 or 解散）   │
├─────────────────────────────────────┤
│ クラン検索・作成画面                   │
│  ├─ 検索（クラン名）                   │
│  ├─ おすすめリスト（人数少ないクラン優先）│
│  └─ 新規作成フォーム（名前・アイコン選択）│
├─────────────────────────────────────┤
│ クランランキング画面                   │
│  └─ 週間クランランキング Top 50        │
│     （既存 LeaderboardScreen と統合可能） │
└─────────────────────────────────────┘
```

既存のリッチUIウィジェット（GlassPanel / GlowButton / RadialBurst）を流用。
既存 LeaderboardScreen のトップ3ハイライトパターンをクランランキングにも再利用する。

---

## 6. KPI 計測（既存9個に追加）

```
clan_joined          — クラン加入
clan_created         — クラン新規作成
clan_left            — クラン脱退（離脱理由の推測に活用: 貢献度の低いメンバーが離脱しやすいか等）
clan_rank_achieved   — 週間クランランキングでのクラン順位確定時
```

**離脱防止の仮説検証**: クラン所属ユーザーと未所属ユーザーの Day7/Day30 リテンションを比較し、
クランが本当にリテンション改善に寄与しているかを Remote Config の A/B テストで検証する
（クラン機能を一部ユーザーにのみ表示するフラグを用意）。

---

## 7. 不正・荒らし対策（最小限）

チャット機能を作らない設計なので、テキストベースの荒らしリスクは低いが、以下は必要：

```
- クラン名・説明文の NGワードフィルタ（Cloud Functions で簡易フィルタ）
- クラン名の重複チェック
- リーダーが長期間非アクティブな場合の自動委譲ロジック
  （30日ログインなし → 次に貢献度が高いメンバーへリーダー権限移譲）
```

---

## 8. 実装フェーズ（推定工数）

```
Phase 1: データモデル + 集計 Cloud Functions              [5-6h]
  - clans / clanRankings スキーマ実装
  - stage_cleared イベントフックでの貢献度加算（トランザクション）
  - 週次リセット・ランキングスナップショット（Cloud Scheduler）

Phase 2: クライアント UI 実装                              [6-8h]
  - クランホーム / 詳細 / 検索・作成 / ランキング 4画面
  - 既存 LeaderboardScreen パターンの再利用

Phase 3: 荒らし対策 + リーダー委譲ロジック                  [3-4h]
  - NGワードフィルタ
  - 非アクティブリーダーの自動委譲バッチ処理

Phase 4: A/Bテスト設計 + KPI検証                            [2-3h]
  - Remote Config でクラン機能フラグ設定
  - Day7/Day30 リテンション比較ダッシュボード（Firebase標準機能で代替可）

合計: 16-21h（PvP実装[25-32h]より軽量。Firebase本設定完了後、PvPと並行 or 後続で着手可能）
```

---

## 9. 前提ブロッカー

```
⏸ Firebase 本設定必須（Firestore + Cloud Functions + Cloud Scheduler）
  → PVP_DESIGN.md と同一ブロッカー。Firebase本設定を1回で両機能分の基盤として整備する。
```

---

## ✅ 設計完了チェック

```
□ Vision（CPU戦・PvPとの三本柱としての役割）が明確
□ スコープを「最小の所属感」に絞り、Won't（チャット/クラン戦/Lv進化）を理由付きで除外
□ データモデル（Firestore schema）定義
□ 集計ロジック（既存 stage_cleared イベント転用で実装コスト削減）定義
□ UI 4画面を洗い出し、既存 LeaderboardScreen パターン流用方針を明記
□ KPI 4個を追加定義 + リテンション仮説検証のA/Bテスト設計
□ 荒らし対策（最小限）を明記
□ 実装フェーズ・工数見積もり完了（16-21h、PvPより軽量）
□ 前提ブロッカー（Firebase本設定、PvPと共通）を明記
→ Firebase 本設定完了後、Phase 1 から実装開始可能
```
