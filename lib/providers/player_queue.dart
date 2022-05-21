import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayerQueueNotifier extends StateNotifier<List<AudioFile>> {
  PlayerQueueNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> add(AudioFile audioFile) async {
    state = [...state, audioFile];

    await ref.read(playlistProvider).add(audioFile.asAudioSource);
  }

  Future<void> addAll(List<AudioFile> audioFiles) async {
    state = [...state, ...audioFiles];

    await ref
        .read(playlistProvider)
        .addAll(audioFiles.map((file) => file.asAudioSource).toList());
  }

  Future<void> clear() async {
    state = [];

    await ref.read(playlistProvider).clear();
  }

  List<AudioFile> get currentQueue => state;
}

final playerQueueProvider =
    StateNotifierProvider<PlayerQueueNotifier, List<AudioFile>>(
        (ref) => PlayerQueueNotifier(ref));
