// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_picker/flutter_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:pomodoro/component/utils.dart';
import 'package:pomodoro/constant/sound.dart';
import 'package:pomodoro/model/shaft/shaft.dart';
import 'package:pomodoro/model/shaft/shaft_state.dart';
import 'package:pomodoro/provider/pomo_provider.dart';
import 'package:pomodoro/provider/shaft_provider.dart';

class PomoViewModel extends Notifier<int> {
  PomoViewModel();

  @override
  int build() => 0;

  /// タイマーを開始する。
  Future<void> startPomo(BuildContext context, WidgetRef ref) async {
    final settingTime = ref.watch(settingTimeProvider);
    final unitOfProgress = 1.0 / settingTime;
    const progress = 0.0;

    ref.read(displayTimeProvider.notifier).update((state) => settingTime);
    startTimer(context, ref, progress, unitOfProgress, settingTime);

    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  /// タイマーを再開する。
  void restartPomo(BuildContext context, WidgetRef ref) {
    final settingTime = ref.watch(settingTimeProvider);
    final remainingTime = ref.watch(remainingTimeProvider);
    final unitOfProgress = 1.0 / settingTime;
    final progress = unitOfProgress * (settingTime - remainingTime);

    ref.read(displayTimeProvider.notifier).update((state) => remainingTime);
    startTimer(context, ref, progress, unitOfProgress, settingTime);

    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  /// タイマーを一時停止する。
  void pausePomo(BuildContext context, WidgetRef ref, int currentProgressTime) {
    ref.read(timerProvider).cancel();
    ref
        .read(remainingTimeProvider.notifier)
        .update((state) => currentProgressTime);
    changePomoPausing(ref);
    debugPrint('pause! reaminingTime is ${ref.watch(remainingTimeProvider)}.');

    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  /// タイマーを終了する。
  void stopPomo(
    BuildContext context,
    WidgetRef ref, {
    required bool isInterruption,
  }) {
    final settingTime = ref.watch(settingTimeProvider);

    if (isInterruption) {
      ref
          .read(shaftViewModelProvider.notifier)
          .countLog(settingTime.toDouble() ~/ 60);
    } else {
      ref.read(shaftViewModelProvider.notifier).countLog(
            (ref.read(settingTimeProvider) - ref.read(remainingTimeProvider))
                    .toDouble() ~/
                60,
          );
    }

    // PomoState を stopping にする。
    changePomoStopping(ref);
    ref.read(timerProvider).cancel();
    ref.read(progressProvider.notifier).update((state) => 0.0);
    ref.read(displayTimeProvider.notifier).update((state) => settingTime);
    ref.read(remainingTimeProvider.notifier).update((state) => 0);

    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  /// タイマーのロジックを担う。
  void startTimer(
    BuildContext context,
    WidgetRef ref,
    double progress,
    double unitOfProgress,
    int settingTime,
  ) {
    final progressBar = ref.watch(progressProvider);
    // PomoState を working に変更する。
    changePomoWorking(ref);
    ref.read(timerProvider.notifier).update(
          (state) => Timer.periodic(
            // 1 秒間隔で進行する。
            const Duration(seconds: 1),
            (Timer timer) async {
              debugPrint('count');
              // 毎秒ディスプレイの数値をカウントダウンする。
              ref.read(displayTimeProvider.notifier).state--;

              // n% / 100% を毎秒進行させる。
              // progressProvider を用いずにローカルの progress でカウントするのは、
              // プログレスが 1.0 を超えるのを先に感知して次の if 文で分岐させるため。
              progress += unitOfProgress;

              // プログレスバーが進行中の場合、バーは進行する（内部的には数値でカウントしている）。
              // 不具合が起きてバーが時間よりも早くカウントされても、0.997（ほぼ 1 に見える）で止まる。
              if (progressBar < 0.997) {
                ref.read(progressProvider.notifier).state += unitOfProgress;
              }

              // プログレスが 1.0 を超えるか、ディスプレイの数値が 0 になった場合、タイマーを終了する。
              if (1.0 <= progress ||
                  ref.watch(displayTimeProvider.notifier).state == 0) {
                stopPomo(context, ref, isInterruption: true);

                await playPool(ref);
              }
            },
          ),
        );
  }

  // ドラムロールで分数選択
  Future<void> timePick(
    BuildContext context,
    WidgetRef ref,
    int settingTime,
  ) async {
    await Picker(
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kHMS,
        value: DateTime(2000, 1, 1, 0, settingTime),
        customColumnType: [3, 4],
      ),
      title: const Text('仕事で何分集中する？'),
      onConfirm: (Picker picker, List<int> time) {
        // 選択した時間を分数に変換する。time[0] => hour, time[1] => min。
        final pickTime = (time[0] * 60 + time[1]) * 60;
        ref.read(settingTimeProvider.notifier).update((state) => pickTime);
        startPomo(context, ref);
      },
    ).showModal<dynamic>(context);
  }

  Future<String> showLog(ShaftState shaft) async {
    final box = await Hive.openBox<Shaft>('shaftsBox');
    debugPrint(shaft.name);
    final log = box.get(
      shaft.name,
      defaultValue: Shaft(
        type: shaft.name,
        totalTime: 0,
        date: DateTime.now(),
      ),
    );

    return log!.totalTime.toString();
  }
}
