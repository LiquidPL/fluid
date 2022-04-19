import 'package:fluid/models/audio_metadata.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayerQueueNotifier extends StateNotifier<List<AudioMetadata>> {
  PlayerQueueNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> add(AudioMetadata song) async {
    state = [...state, song];

    await ref.read(playlistProvider).add(song.asAudioSource);
  }

  Future<void> addAll(List<AudioMetadata> songs) async {
    state = [...state, ...songs];

    await ref
        .read(playlistProvider)
        .addAll(songs.map((song) => song.asAudioSource).toList());
  }

  Future<void> clear() async {
    state = [];

    await ref.read(playlistProvider).clear();
  }

  List<AudioMetadata> get currentQueue => state;
}

final playerQueueProvider =
    StateNotifierProvider<PlayerQueueNotifier, List<AudioMetadata>>(
        (ref) => PlayerQueueNotifier(ref));
