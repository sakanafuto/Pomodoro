// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:pomodoro/model/pomo/pomo_state.dart';
import 'package:pomodoro/screen/pomo/pomo_view_model.dart';

// タイマーを監視する。
final timerProvider = StateProvider<Timer>(
  (ref) => Timer.periodic(const Duration(seconds: 1), (Timer _) {}),
);

// pomoViewModel を監視する。
final pomoViewModelProvider =
    NotifierProvider<PomoViewModel, int>(PomoViewModel.new);

// ドラムロールで選択した時間を監視する。
final settingTimeProvider = StateProvider<int>((ref) => 1 * 60);

// 一時停止した際の残りの時間を監視する。
final remainingTimeProvider = StateProvider<int>((ref) => 0);

// プログレスバーを監視する。
final progressProvider = StateProvider<double>((ref) => 0);

// プログレスバーの上に表示する数字を監視する。
final displayTimeProvider = StateProvider<int>((ref) => 60 * 1);

// Pomo の状態を監視する。
final pomoStateProvider = StateProvider<PomoState>((ref) => PomoState.stopping);

// FAB のアイコンを監視する。
final iconProvider =
    StateProvider<Widget>((ref) => const Icon(Icons.play_arrow));
