import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'domain/models/habit.dart';
import 'domain/models/habit_entry.dart';
import 'data/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Isar? isar;
  if (kIsWeb) {
    isar = await Isar.open(
      [HabitSchema, HabitEntrySchema],
      directory: 'isar_data',
    );
  } else {
    try {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        [HabitSchema, HabitEntrySchema],
        directory: dir.path,
      );
    } catch (e) {
      // Fallback
      isar = await Isar.open(
        [HabitSchema, HabitEntrySchema],
        directory: '.',
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const HabitFlowApp(),
    ),
  );
}
