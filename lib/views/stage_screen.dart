import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/index.dart';
import '../viewmodels/game_state.dart';
import '../viewmodels/commander_provider.dart';
import '../viewmodels/player_provider.dart';
import '../viewmodels/deck_provider.dart';
import '../services/analytics_provider.dart';
import '../widgets/glow_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/rich_hp_bar.dart';
import '../widgets/screen_shake.dart';
import '../widgets/hit_flash.dart';
import '../widgets/damage_popup.dart';
import 'stage_victory_screen.dart';
import 'stage_defeat_screen.dart';

class StageScreen extends ConsumerStatefulWidget {
  final int stageId;

  const StageScreen({
    super.key,
    required this.stageId,
  });

  @override
  ConsumerState<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends ConsumerState<StageScreen>
    with TickerProviderStateMixin {
  late Stage stage;
  late int enemyHP;
  late int enemyHPMax;
  late int playerHP;
  int elapsedSeconds = 0;
  bool isGameOver = false;
  bool isVictory = false;
  int _comboCount = 0;
  int _totalDamageDealt = 0;
  int _totalDamageTaken = 0;
  int? _lastHealSecond;

  static const int _healCooldownSeconds = 15;
  static const int _playerMaxHP = 150;

  final ScreenShakeController _shakeController = ScreenShakeController();
  final HitFlashController _flashController = HitFlashController();
  final List<DamagePopupData> _popups = [];
  int _popupIdCounter = 0;

  late AnimationController _attackPulseController;

  @override
  void initState() {
    super.initState();
    _initStage();
    _startTimer();
    _attackPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _attackPulseController.dispose();
    super.dispose();
  }

  void _initStage() {
    // ステージ難度: ステージ1は必ずクリア可能な固定難度、
    // ステージ2以上は日替わりAI司令官の性格（EnemyAIEngine）に基づいてHPを決定する
    final commander = ref.read(commanderProvider);
    final aiEngine = EnemyAIEngine(commander);

    int baseHealth;
    if (widget.stageId == 1) {
      baseHealth = 60; // ステージ1: 簡単（必ずクリア可能。司令官の性格に依らず固定）
    } else if (widget.stageId == 2) {
      baseHealth = aiEngine.getEnemyHP(); // 司令官の性格に応じたHP（初敗北の経験）
    } else {
      baseHealth = aiEngine.getEnemyHP() + ((widget.stageId - 2) * 30);
    }

    stage = Stage(
      stageId: widget.stageId,
      difficulty: widget.stageId,
      enemyHealth: baseHealth,
      enemyUnitIds: ['unit_1', 'unit_2'],
      mineralReward: 10 + (widget.stageId * 5),
    );
    enemyHP = stage.enemyHealth;
    enemyHPMax = stage.enemyHealth;
    playerHP = _playerMaxHP;
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isGameOver && mounted) {
        setState(() {
          elapsedSeconds++;
          if (elapsedSeconds >= 120) {
            // 2分経過→敗北
            _endGame(victory: false);
          }
        });
        _startTimer();
      }
    });
  }

  void _addPopup(
    int amount,
    Color color, {
    bool isCritical = false,
    bool isHeal = false,
    required double dx,
  }) {
    final popup = DamagePopupData(
      id: _popupIdCounter++,
      amount: amount,
      color: color,
      isCritical: isCritical,
      isHeal: isHeal,
      origin: Offset(dx, 0),
    );
    setState(() => _popups.add(popup));
  }

  void _removePopup(int id) {
    setState(() => _popups.removeWhere((p) => p.id == id));
  }

  /// デッキに含まれる Healer ユニットを取得（いなければ null）
  Unit? _findHealerInDeck() {
    final deck = ref.read(deckProvider);
    final playerData = ref.read(playerDataProvider);
    for (final unit in playerData.units) {
      if (unit.unitType == 'Healer' && deck.unitIds.contains(unit.id)) {
        return unit;
      }
    }
    return null;
  }

  /// 回復クールタイムの残り秒数（0ならすぐ使用可能）
  int _healCooldownRemaining() {
    if (_lastHealSecond == null) return 0;
    final remaining = _healCooldownSeconds - (elapsedSeconds - _lastHealSecond!);
    return remaining > 0 ? remaining : 0;
  }

  void _heal() {
    if (isGameOver) return;
    if (_healCooldownRemaining() > 0) return;

    final healer = _findHealerInDeck();
    if (healer == null) return;

    final healAmount = healer.getHealAmount();
    final actualHeal = (playerHP + healAmount > _playerMaxHP)
        ? (_playerMaxHP - playerHP)
        : healAmount;
    if (actualHeal <= 0) return;

    _addPopup(actualHeal, ColorPalette.victoryGreenBright, isHeal: true, dx: 170);

    setState(() {
      playerHP += actualHeal;
      _lastHealSecond = elapsedSeconds;
    });
  }

  void _attack() {
    if (isGameOver) return;

    // ステージ1は必ずクリア可能な固定バランス、ステージ2以上は
    // 日替わりAI司令官の性格（EnemyAIEngine）に応じた反撃ダメージにする
    int damageDealt = widget.stageId == 1 ? 20 : 15;
    int enemyCounterDamage = widget.stageId == 1
        ? 5
        : EnemyAIEngine(ref.read(commanderProvider)).getEnemyAttackDamage();

    _comboCount++;
    final isCritical = _comboCount % 4 == 0;
    final critMultiplier = isCritical ? 2 : 1;
    final totalDamage = damageDealt * critMultiplier;

    // 演出: 画面シェイク + ヒットフラッシュ + ダメージポップ
    _shakeController.trigger(intensity: isCritical ? 14 : 7);
    _flashController.trigger(
      color: isCritical ? ColorPalette.goldBright : ColorPalette.dangerBright,
    );
    _addPopup(totalDamage, isCritical ? ColorPalette.goldBright : Colors.white,
        isCritical: isCritical, dx: 120);
    _addPopup(enemyCounterDamage, ColorPalette.dangerBright, dx: 220);

    setState(() {
      enemyHP -= totalDamage;
      playerHP -= enemyCounterDamage;
      _totalDamageDealt += totalDamage;
      _totalDamageTaken += enemyCounterDamage;

      if (enemyHP <= 0) {
        enemyHP = 0;
        _endGame(victory: true);
      } else if (playerHP <= 0) {
        playerHP = 0;
        _endGame(victory: false);
      }
    });
  }

  void _endGame({required bool victory}) {
    setState(() {
      isGameOver = true;
      isVictory = victory;
    });

    final analytics = ref.read(analyticsProvider);

    if (victory) {
      GameStateHelper.clearStage(ref, widget.stageId);

      // Analytics: ステージクリアイベント
      analytics.logStageCleared(
        stageId: widget.stageId,
        starCount: 3,
        mineralEarned: stage.mineralReward,
      );

      // チュートリアル完了（ステージ1クリア）
      if (widget.stageId == 1) {
        analytics.logOnboardingComplete();
      }

      // Aha Moment に到達した場合
      if (widget.stageId == 2) {
        GameStateHelper.reachAhaMoment(ref);
        // Analytics: Aha Moment 到達イベント
        analytics.logAhaMomentReached(
          stageId: widget.stageId,
          timeTakenSeconds: elapsedSeconds,
        );
      }

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StageVictoryScreen(
                stageId: widget.stageId,
                mineralReward: stage.mineralReward,
                starsEarned: 3,
              ),
            ),
          );
        }
      });
    } else {
      final playerData = ref.read(playerDataProvider);
      final unitLevels = {
        for (final unit in playerData.units) unit.id: unit.level,
      };

      final battleLog = BattleLog(
        stageId: widget.stageId,
        victory: false,
        elapsedSeconds: elapsedSeconds,
        totalDamageDealt: _totalDamageDealt,
        totalDamageTaken: _totalDamageTaken,
        finalPlayerHP: playerHP,
        finalEnemyHP: enemyHP,
        enemyHPMax: enemyHPMax,
        unitLevels: unitLevels,
      );

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StageDefeatScreen(
                stageId: widget.stageId,
                battleLog: battleLog,
              ),
            ),
          );
        }
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    String secStr = secs.toString().padLeft(2, '0');
    return '$minutes:$secStr';
  }

  Color _getPersonalityColor(String personality) {
    switch (personality) {
      case 'Aggressive':
        return ColorPalette.danger;
      case 'Defensive':
        return ColorPalette.turquoise;
      case 'Balanced':
      default:
        return ColorPalette.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final commander = ref.watch(commanderProvider);
    final aiEngine = EnemyAIEngine(commander);
    final personalityColor = _getPersonalityColor(commander.personality);
    final isTimeCritical = elapsedSeconds >= 100;
    final healer = _findHealerInDeck();
    final healCooldown = _healCooldownRemaining();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ステージ ${widget.stageId}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              commander.name,
              style: TextStyle(fontSize: 12, color: personalityColor),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: HitFlash(
        controller: _flashController,
        child: ScreenShake(
          controller: _shakeController,
          child: Container(
            decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 60),

                      // 敵司令官表示
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: GlassPanel(
                          borderColor: personalityColor,
                          withGlow: true,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            aiEngine.getCommanderDescription(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: ColorPalette.lightText),
                          ),
                        ),
                      ),

                      // タイマー
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isTimeCritical ? 56 : 48,
                            fontWeight: FontWeight.w900,
                            color: isTimeCritical ? ColorPalette.dangerBright : ColorPalette.accentOrangeBright,
                            shadows: [
                              Shadow(
                                color: (isTimeCritical ? ColorPalette.danger : ColorPalette.accentOrange)
                                    .withValues(alpha: 0.8),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Text(_formatTime(elapsedSeconds)),
                        ),
                      ),

                      // 敵HP
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '敵 HP',
                              style: TextStyle(
                                color: ColorPalette.dangerBright,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichHpBar(
                              current: enemyHP,
                              max: enemyHPMax,
                              color: ColorPalette.danger,
                              glowColor: ColorPalette.dangerBright,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$enemyHP / $enemyHPMax',
                              style: const TextStyle(fontSize: 12, color: ColorPalette.lightText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 味方HP
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '味方 HP',
                              style: TextStyle(
                                color: ColorPalette.turquoiseBright,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichHpBar(
                              current: playerHP,
                              max: _playerMaxHP,
                              color: ColorPalette.turquoise,
                              glowColor: ColorPalette.turquoiseBright,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$playerHP / $_playerMaxHP',
                              style: const TextStyle(fontSize: 12, color: ColorPalette.lightText),
                            ),
                          ],
                        ),
                      ),

                      // コンボ表示
                      if (_comboCount > 1 && !isGameOver)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            '$_comboCount COMBO',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: ColorPalette.goldBright,
                              shadows: [
                                Shadow(color: ColorPalette.gold.withValues(alpha: 0.8), blurRadius: 16),
                              ],
                            ),
                          ),
                        ),

                      const Spacer(),

                      // 攻撃ボタン（+ Healerがデッキにいれば回復ボタン）/ 結果表示
                      if (!isGameOver)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _attackPulseController,
                                builder: (context, child) {
                                  final glowBoost = 0.85 + (0.3 * _attackPulseController.value);
                                  return Transform.scale(scale: glowBoost, child: child);
                                },
                                child: GlowButton(
                                  label: '攻撃',
                                  icon: Icons.flash_on,
                                  gradient: ColorPalette.orangeAura,
                                  glowColor: ColorPalette.accentOrange,
                                  fontSize: 22,
                                  onPressed: _attack,
                                ),
                              ),
                              if (healer != null) ...[
                                const SizedBox(width: 14),
                                GlowButton(
                                  label: healCooldown > 0 ? '${healCooldown}s' : '回復',
                                  icon: Icons.favorite_rounded,
                                  gradient: ColorPalette.victoryAura,
                                  glowColor: ColorPalette.victoryGreen,
                                  fontSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                                  onPressed: healCooldown > 0 ? null : _heal,
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            isVictory ? '勝利！' : '敗北…',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: isVictory ? ColorPalette.victoryGreenBright : ColorPalette.dangerBright,
                              shadows: [
                                Shadow(
                                  color: (isVictory ? ColorPalette.victoryGreen : ColorPalette.danger)
                                      .withValues(alpha: 0.9),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ダメージポップアップ層
                  ..._popups.map(
                    (p) => DamagePopup(
                      key: ValueKey(p.id),
                      data: p,
                      onCompleted: () => _removePopup(p.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
