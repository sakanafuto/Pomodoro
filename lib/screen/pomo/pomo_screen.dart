// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Project imports:
import 'package:pomodoro/component/floating_action_button_screen.dart';
import 'package:pomodoro/component/size_route.dart';
import 'package:pomodoro/constant/sound.dart';
import 'package:pomodoro/provider/pomo_provider.dart';
import 'package:pomodoro/screen/pomo/zen_screen.dart';

/// TODO: タイマーの記憶

class PomoScreen extends ConsumerStatefulWidget {
  const PomoScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PomoScreenState();
}

class PomoScreenState extends ConsumerState<PomoScreen>
    with WidgetsBindingObserver {
  late DateTime _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _handlePaused(WidgetRef ref) {
    final currentTime = ref.watch(displayTimeProvider);

    // タイマーが動いている状態でバックグランドに移行している
    if (ref.read(timerProvider).isActive) {
      debugPrint('timer is working');
      ref
          .read(pomoViewModelProvider.notifier)
          .pausePomo(context, ref, currentTime);
    }

    // バックグラウンドに遷移した時間を記録
    _pausedTime = DateTime.now();
    debugPrint('paused!');
  }

  void _handleResumed(WidgetRef ref) {
    final settingTime = ref.read(settingTimeProvider);
    final remainingTime = ref.read(remainingTimeProvider);
    // タイマーが動いてなければ何もしない
    if (ref.read(timerProvider).isActive) {
      debugPrint('timer is not working');
      return;
    }

    // バックグラウンドでの経過時間
    final backgroundDuration = DateTime.now().difference(_pausedTime).inSeconds;
    debugPrint('background for ${backgroundDuration.toString()} seconds');

    // バックグラウンドで経過した時間分進める
    ref
        .read(remainingTimeProvider.notifier)
        .update((state) => remainingTime - backgroundDuration);
    debugPrint(
      'remainingTime is ${ref.read(remainingTimeProvider).toString()}',
    );

    // バックグラウンドで経過した時間が設定時間を超えていた場合、ポモを止める
    if (ref.read(remainingTimeProvider) <= 0) {
      debugPrint('over');
      ref
          .read(pomoViewModelProvider.notifier)
          .stopPomo(context, ref, isInterruption: true);
      debugPrint(ref.read(displayTimeProvider).toString());
      return;
    }

    // ポモを再開する
    ref.read(pomoViewModelProvider.notifier).restartPomo(context, ref);

    // プログレスバーを進める
    ref.read(progressProvider.notifier).update(
          (state) =>
              (settingTime - ref.read(remainingTimeProvider)) / settingTime,
        );
    debugPrint('resumed!');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // バックグラウンドに遷移した時
      _handlePaused(ref);
      stopPool(ref, pool);
    } else if (state == AppLifecycleState.resumed) {
      // フォアグラウンドに復帰した時
      _handleResumed(ref);
      stopPool(ref, pool);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = ref.watch(progressProvider);
    final displayTime = ref.watch(displayTimeProvider);
    final isSoundPlaying = ref.watch(isSoundPlayingProvider);

    final minute = displayTime ~/ 60;
    final second = displayTime - (minute * 60);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push<dynamic>(
                context,
                SizeRoute(
                  page: GestureDetector(
                    onTap: () => Navigator.popUntil(
                      context,
                      (Route<dynamic> route) => route.isFirst,
                    ),
                    child: const ZenScreen(),
                  ),
                ),
              ),
              child: Text(
                '$minute : $second',
                style: const TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const Gap(40),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              // child: buildLibearIndicator(percent),
              child: buildCircularIndicator(percent, size.width),
            ),
          ),
          const Gap(40),
          isSoundPlaying
              ? OutlinedButton(
                  onPressed: () async => stopPool(ref, pool),
                  child: const Text('stop'),
                )
              : const SizedBox(),
        ],
      ),
      floatingActionButton: const FloatingActionButtonScreen(),
    );
  }

  LinearPercentIndicator buildLibearIndicator(double percent) {
    return LinearPercentIndicator(
      progressColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      percent: percent,
      animation: true,
      animateFromLastPercent: true,
      lineHeight: 8,
      barRadius: const Radius.circular(16),
    );
  }

  CircularPercentIndicator buildCircularIndicator(
    double percent,
    double displayWidth,
  ) {
    return CircularPercentIndicator(
      progressColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      percent: percent,
      animation: true,
      animateFromLastPercent: true,
      radius: displayWidth * .3,
    );
  }
}
