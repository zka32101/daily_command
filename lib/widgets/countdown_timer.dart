import 'dart:async';
import 'package:flutter/material.dart';

/// 1秒毎に残り時間を更新して表示するカウントダウンテキスト
class CountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  final TextStyle? style;
  final VoidCallback? onExpired;

  const CountdownTimer({
    super.key,
    required this.expiresAt,
    this.style,
    this.onExpired,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _expiredFired = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final diff = widget.expiresAt.difference(DateTime.now());
    final remaining = diff.isNegative ? Duration.zero : diff;

    if (mounted) {
      setState(() => _remaining = remaining);
    }

    if (remaining == Duration.zero && !_expiredFired) {
      _expiredFired = true;
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_format(_remaining), style: widget.style);
  }
}
