import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

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
