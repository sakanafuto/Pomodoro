// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:pomodoro/constant/colors.dart';
import 'package:pomodoro/model/shaft/shaft.dart';
import 'package:pomodoro/model/shaft/shaft_state.dart';
import 'package:pomodoro/screen/setting/setting_screen.dart';
import 'package:pomodoro/screen/shaft/shaft_log.dart';
import 'package:pomodoro/screen/shaft/shaft_select_screen.dart';

class DrawerScreen extends HookConsumerWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomoLog = Shaft(
      type: ShaftState.work.toString(),
      totalTime: 20,
      date: DateTime.now(),
    );

    return Drawer(
      width: 340,
      child: SafeArea(
        child: Row(
          children: <Widget>[
            const Gap(32),
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Gap(32),
                TextButton(
                  child: Text(
                    'Simple Pomo',
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  onPressed: () async {
                    final box = await Hive.openBox<Shaft>('shaftsBox');
                    await box.put('work', pomoLog);

                    debugPrint('Total: ${box.get('work')?.type}');
                    debugPrint(
                        'Total: ${box.get('work')?.totalTime.toString()}',);
                    debugPrint('Total: ${box.get('work')?.date.toString()}');
                  },
                ),
                const Gap(64),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: (context) => const ShaftLog(),
                      ),
                    );
                  },
                  child: const Text(
                    '# 追跡',
                    style: TextStyle(color: subTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: (context) => const ShaftSelectScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '# 軸　',
                    style: TextStyle(color: subTextColor),
                  ),
                ),
                const Gap(80),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: (context) => const SettingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, color: subTextColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
