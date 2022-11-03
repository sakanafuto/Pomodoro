// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_picker/flutter_picker.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:pomodoro/component/size_route.dart';
import 'package:pomodoro/constant/colors.dart';
import 'package:pomodoro/model/pomo/pomo_state.dart';
import 'package:pomodoro/model/shaft/shaft_state.dart';
import 'package:pomodoro/provider/pomo_provider.dart';
import 'package:pomodoro/provider/shaft_provider.dart';
import 'package:pomodoro/screen/pomo/zen_screen.dart';

class FloatingActionButtonScreen extends ConsumerWidget {
  const FloatingActionButtonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pomoViewModelProvider);
    final currentTime = ref.watch(displayTimeProvider);
    final settingTime = ref.watch(settingTimeProvider) ~/ 60;
    final icon = ref.watch(iconProvider);
    final shaftState = ref.watch(shaftStateProvider);

    // ドラムロールで分数選択
    Future<void> timePick() async {
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
          viewModel.startPomo(context, ref);
        },
      ).showModal<dynamic>(context);
    }

    /// TODO: 長すぎ。ファイルに分けたい。
    Future<dynamic> switchFAB() {
      switch (ref.watch(pomoStateProvider.notifier).state) {
        // タイマーが動いているときは終了もしくは一時停止できる。
        case PomoState.working:
          return Navigator.push<dynamic>(
            context,
            SizeRoute(
              page: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 1000,
                  width: 1000,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () =>
                                    viewModel.stopPomo(context, ref),
                                child: const Text(
                                  'ポモを終了する',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () => Navigator.push<dynamic>(
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
                                child: const Text(
                                  '禅',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () => viewModel.pausePomo(
                                  context,
                                  ref,
                                  currentTime,
                                ),
                                child: const Text(
                                  '一時停止',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        // タイマーが一時停止中のときは終了もしくは再開ができる。
        case PomoState.pausing:
          return Navigator.push<dynamic>(
            context,
            SizeRoute(
              page: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 1000,
                  width: 1000,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () =>
                                    viewModel.stopPomo(context, ref),
                                child: const Text(
                                  'ポモを終了する',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () =>
                                    viewModel.restartPomo(context, ref),
                                child: const Text(
                                  '再開',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        // タイマーが終了しているときは新しく始めることができる。
        case PomoState.stopping:
          return Navigator.push<dynamic>(
            context,
            SizeRoute(
              page: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 1000,
                  width: 1000,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push<dynamic>(
                                    context,
                                    SizeRoute(
                                      page: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          height: 1000,
                                          width: 1000,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          child: SafeArea(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .background,
                                                      margin:
                                                          const EdgeInsets.all(
                                                        16,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                shaftStateProvider
                                                                    .notifier,
                                                              )
                                                              .update(
                                                                (state) =>
                                                                    ShaftState
                                                                        .work,
                                                              );
                                                          ref
                                                              .watch(
                                                                shaftSelectorProvider
                                                                    .notifier,
                                                              )
                                                              .change(
                                                                ShaftState.work,
                                                              );
                                                          timePick();
                                                        },
                                                        child: const Text(
                                                          '仕事',
                                                          style: TextStyle(
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .background,
                                                      margin:
                                                          const EdgeInsets.all(
                                                        16,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                shaftStateProvider
                                                                    .notifier,
                                                              )
                                                              .update(
                                                                (state) =>
                                                                    ShaftState
                                                                        .hoby,
                                                              );
                                                          ref
                                                              .watch(
                                                                shaftSelectorProvider
                                                                    .notifier,
                                                              )
                                                              .change(
                                                                ShaftState.hoby,
                                                              );
                                                          timePick();
                                                        },
                                                        child: const Text(
                                                          '趣味',
                                                          style: TextStyle(
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .background,
                                                      margin:
                                                          const EdgeInsets.all(
                                                        16,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                shaftStateProvider
                                                                    .notifier,
                                                              )
                                                              .update(
                                                                (state) =>
                                                                    ShaftState
                                                                        .rest,
                                                              );
                                                          ref
                                                              .watch(
                                                                shaftSelectorProvider
                                                                    .notifier,
                                                              )
                                                              .change(
                                                                ShaftState.rest,
                                                              );
                                                          timePick();
                                                        },
                                                        child: const Text(
                                                          '休息',
                                                          style: TextStyle(
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '軸を変更する。',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              margin: const EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: timePick,
                                child: Text(
                                  '\'$shaftState\'で集中する',
                                  style: const TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            )
                          ],
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

    return FloatingActionButton(
      // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      // shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: switchFAB,
      child: icon,
    );
  }
}
