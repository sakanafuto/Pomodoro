// Flutter imports:

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:pomodoro/constant/colors.dart';
import 'package:pomodoro/constant/sound.dart';
import 'package:pomodoro/model/shaft/shaft.dart';
import 'package:pomodoro/provider/shaft_provider.dart';
import 'package:pomodoro/screen/setting/setting_screen.dart';
import 'package:pomodoro/screen/shaft/shaft_log_screen.dart';
import 'package:pomodoro/screen/shaft/shaft_select_screen.dart';

class DrawerScreen extends HookConsumerWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 340,
      child: SafeArea(
        child: Row(
          children: <Widget>[
            const Gap(32),
            Column(
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
                    await playPool(ref);

                    final box = await Hive.openBox<Shaft>('shaftsBox');

                    final workLog = box.get('work');

                    const sampleInt = 30;
                    workLog!.totalTime += sampleInt;

                    await box.put('work', workLog);
                    debugPrint(
                      '${ref.watch(shaftViewModelProvider)}, ${box.get('work')?.totalTime.toString()}',
                    );
                  },
                ),
                const Gap(64),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: (context) => const ShaftLogScreen(),
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
