import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/permission_service.dart';
import 'package:fluid/providers/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaStore {
  const MediaStore(this.ref, this.query);

  final Ref ref;
  final OnAudioQuery query;

  Future<void> scan() async {
    final permissionService = ref.read(permissionServiceProvider);
    const permission = Permission.storage;

    if (await permissionService.status(permission).isDenied) {
      await permissionService.request(permission);
    }

    final songs = await query.querySongs(
      filter: MediaFilter.forSongs(
        type: {
          AudioType.IS_MUSIC: true,
          AudioType.IS_ALARM: false,
          AudioType.IS_NOTIFICATION: false,
          AudioType.IS_RINGTONE: false,
        },
      ),
    );

    final database = ref.read(databaseProvider);

    await database.writeTxn(
      (database) async {
        for (final rawAudioFile in songs) {
          if (rawAudioFile.uri == null) {
            continue;
          }

          final audioFile = AudioFile(
            id: rawAudioFile.id,
            uri: rawAudioFile.uri!,
            title: rawAudioFile.title,
            artist: rawAudioFile.artist ?? '',
            duration: Duration(milliseconds: rawAudioFile.duration ?? 0),
          );

          await database.audioFiles.put(audioFile);
        }
      },
    );
  }
}

final mediaStoreProvider =
    Provider<MediaStore>((ref) => MediaStore(ref, OnAudioQuery()));
