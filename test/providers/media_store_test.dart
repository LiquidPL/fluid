import 'package:fluid/providers/media_store.dart';
import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/permission_service.dart';
import 'package:fluid/providers/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers.dart';
import 'media_store_test.mocks.dart';

Future<Isar> _openDatabase() async {
  final tempDir = await getTemporaryDirectory();
  final isarDir = await tempDir.createTemp('isar');

  return Isar.open(
    schemas: [AudioFileSchema],
    directory: isarDir.path,
  );
}

@GenerateMocks([OnAudioQuery, PermissionService])
void main() async {
  setUp(() async => Isar.initializeIsarCore(download: true));

  group('songs', () {
    test('stores a valid AudioFile in database', () async {
      final query = MockOnAudioQuery();
      final permissionService = MockPermissionService();

      when(permissionService.status(Permission.storage)).thenAnswer(
          (_) => Future<PermissionStatus>.value(PermissionStatus.granted));

      when(query.querySongs(filter: anyNamed('filter'))).thenAnswer(
          (_) => Future<List<AudioModel>>.value(createListOfAudioModels(1)));

      final isar = await _openDatabase();
      addTearDown(isar.close);

      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(permissionService),
          databaseProvider.overrideWithValue(isar),
          mediaStoreProvider.overrideWithProvider(
            Provider((ref) => MediaStore(ref, query)),
          ),
        ],
      );
      addTearDown(container.dispose);

      await (container.read(mediaStoreProvider)).scan();

      final file = await isar.audioFiles.get(0);

      expect(await isar.audioFiles.count(), 1);

      expect(file, isNotNull);

      expect(file!.title, 'song 0');
      expect(file.artist, 'test artist');
      expect(file.uri, 'asset:///integration_test/assets/silence_1m40s.ogg');
      expect(file.duration, const Duration(minutes: 1, seconds: 40));
    });

    test('stores multiple AudioFiles in database', () async {
      final query = MockOnAudioQuery();
      final permissionService = MockPermissionService();

      when(permissionService.status(Permission.storage)).thenAnswer(
          (_) => Future<PermissionStatus>.value(PermissionStatus.granted));

      when(query.querySongs(filter: anyNamed('filter'))).thenAnswer(
          (_) => Future<List<AudioModel>>.value(createListOfAudioModels(4)));

      final isar = await _openDatabase();
      addTearDown(isar.close);

      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(permissionService),
          databaseProvider.overrideWithValue(isar),
          mediaStoreProvider.overrideWithProvider(
            Provider((ref) => MediaStore(ref, query)),
          ),
        ],
      );
      addTearDown(container.dispose);

      await (container.read(mediaStoreProvider)).scan();

      expect(await isar.audioFiles.count(), 4);
    });

    test('checks for storage permissions before syncing', () async {
      final query = MockOnAudioQuery();
      final permissionService = MockPermissionService();

      when(permissionService.status(Permission.storage)).thenAnswer(
          (_) => Future<PermissionStatus>.value(PermissionStatus.granted));

      when(query.querySongs(filter: anyNamed('filter')))
          .thenAnswer((_) => Future<List<AudioModel>>.value([]));

      final isar = await _openDatabase();
      addTearDown(isar.close);

      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(permissionService),
          databaseProvider.overrideWithValue(isar),
          mediaStoreProvider.overrideWithProvider(
            Provider((ref) => MediaStore(ref, query)),
          ),
        ],
      );
      addTearDown(container.dispose);

      await (container.read(mediaStoreProvider)).scan();

      verify(permissionService.status(Permission.storage)).called(1);
      verifyNoMoreInteractions(permissionService);
    });

    test('requests storage permissions before syncing if not granted',
        () async {
      final query = MockOnAudioQuery();
      final permissionService = MockPermissionService();

      when(permissionService.status(Permission.storage)).thenAnswer(
          (_) => Future<PermissionStatus>.value(PermissionStatus.denied));

      when(permissionService.request(Permission.storage)).thenAnswer(
          (_) => Future<PermissionStatus>.value(PermissionStatus.granted));

      when(query.querySongs(filter: anyNamed('filter')))
          .thenAnswer((_) => Future<List<AudioModel>>.value([]));

      final isar = await _openDatabase();
      addTearDown(isar.close);

      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(permissionService),
          databaseProvider.overrideWithValue(isar),
          mediaStoreProvider.overrideWithProvider(
            Provider((ref) => MediaStore(ref, query)),
          ),
        ],
      );
      addTearDown(container.dispose);

      await (container.read(mediaStoreProvider)).scan();

      verify(permissionService.status(Permission.storage)).called(1);
      verify(permissionService.request(Permission.storage)).called(1);
      verifyNoMoreInteractions(permissionService);
    });
  });
}
