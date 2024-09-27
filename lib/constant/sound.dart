import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soundpool/soundpool.dart';

final isSoundPlayingProvider = StateProvider<bool>((ref) => false);

final pool = Soundpool.fromOptions(
  options: const SoundpoolOptions(
    maxStreams: 5,
  ),
);

bool isIos = Platform.isIOS;

Future<void> playPool(WidgetRef ref) async {
  final phone1Id =
      await rootBundle.load('assets/se/phone1.mp3').then(pool.load);

  if (phone1Id > 0 && isIos) {
    await pool.stop(phone1Id);
  }
  await pool.play(phone1Id);

  ref.read(isSoundPlayingProvider.notifier).update((state) => true);
}

Future<void> stopPool(WidgetRef ref, Soundpool pool) async {
  await pool
      .stop(await rootBundle.load('assets/se/phone1.mp3').then(pool.load));
  ref.read(isSoundPlayingProvider.notifier).update((state) => false);
}
