import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/permission_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

final playlistProvider =
    Provider<ConcatenatingAudioSource>((ref) => ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: [],
        ));

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();

  player.setAudioSource(ref.read(playlistProvider));

  return player;
});

final isPlayingProvider =
    StreamProvider<bool>((ref) => ref.watch(audioPlayerProvider).playingStream);

final durationProvider = StreamProvider<Duration?>(
    (ref) => ref.watch(audioPlayerProvider).durationStream);

final positionProvider = StreamProvider<Duration?>(
    (ref) => ref.watch(audioPlayerProvider).positionStream);

final currentQueueIndexProvider = StreamProvider<int?>((ref) => ref
    .watch(audioPlayerProvider)
    .sequenceStateStream
    .map((state) => state?.currentIndex));

final currentAudioFileProvider = StreamProvider<AudioFile?>((ref) => ref
    .watch(audioPlayerProvider)
    .sequenceStateStream
    .map((state) => state?.currentSource?.tag));

final currentArtworkModelProvider = FutureProvider<ArtworkModel?>((ref) async {
  if (await ref
      .read(permissionServiceProvider)
      .status(Permission.storage)
      .isDenied) {
    return null;
  }

  final audioFile = ref.watch(currentAudioFileProvider).value;

  if (audioFile == null || audioFile.id == null) {
    return null;
  }

  return OnAudioQuery().queryArtwork(
    audioFile.id!,
    ArtworkType.AUDIO,
    filter: MediaFilter.forArtwork(
      artworkFormat: ArtworkFormat.PNG,
      artworkSize: 1000,
    ),
  );
});

final artworkModelProvider = FutureProvider.family<ArtworkModel?, int>(
  (ref, id) async {
    if (await ref
        .read(permissionServiceProvider)
        .status(Permission.storage)
        .isDenied) {
      return null;
    }

    return OnAudioQuery().queryArtwork(
      id,
      ArtworkType.AUDIO,
      filter: MediaFilter.forArtwork(
        artworkFormat: ArtworkFormat.PNG,
        artworkSize: 250,
      ),
    );
  },
);

final songTitleProvider = StreamProvider<String>(
    (ref) => ref.watch(audioPlayerProvider).sequenceStateStream.map((state) {
          if (state == null ||
              state.currentSource == null ||
              state.currentSource!.tag == null) {
            return '';
          }

          return state.currentSource!.tag.title;
        }));

final songArtistProvider = StreamProvider<String>(
    (ref) => ref.watch(audioPlayerProvider).sequenceStateStream.map((state) {
          if (state == null ||
              state.currentSource == null ||
              state.currentSource!.tag == null) {
            return '';
          }

          return state.currentSource!.tag.artist;
        }));
