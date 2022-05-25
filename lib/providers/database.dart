import 'dart:io';

import 'package:fluid/models/audio_file.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// The database path needs to be in a FutureProvider so that it can be
/// acquired asynchronously and then set on the database in [databaseProvider]
///
/// [FutureProvider.future] needs to be awaited at some time before
/// [databaseProvider] is first read (preferably in main()) so that it's
/// initialized
final databasePathProvider =
    FutureProvider<Directory>((ref) => getApplicationDocumentsDirectory());

final databaseProvider = Provider<Isar>((ref) {
  final dir = ref.read(databasePathProvider).value;

  return Isar.openSync(
    schemas: [AudioFileSchema],
    directory: dir!.path,
    inspector: true,
  );
});
