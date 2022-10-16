// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:pomodoro/model/shaft/shaft_state.dart';

part 'shaft.g.dart';

@HiveType(typeId: 0, adapterName: 'ShaftAdapter')
class Shaft extends HiveObject {
  Shaft({required this.type, required this.totalTime, required this.date});
  @HiveField(0, defaultValue: ShaftState.work)
  final ShaftState type;

  @HiveField(1)
  final int totalTime;

  @HiveField(2)
  final DateTime date;
}
