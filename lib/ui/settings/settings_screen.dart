// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pomodoro/ui/component/app_bar_screen.dart';
import 'package:pomodoro/ui/component/drawer_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarScreen(),
      drawer: DrawerScreen(),
      body: SizedBox(),
    );
  }
}
