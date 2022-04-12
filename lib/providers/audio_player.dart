import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());

final isPlayingProvider =
    StreamProvider<bool>((ref) => ref.watch(audioPlayerProvider).playingStream);

final durationProvider = StreamProvider<Duration?>(
    (ref) => ref.watch(audioPlayerProvider).durationStream);

final progressProvider = StreamProvider<Duration?>(
    (ref) => ref.watch(audioPlayerProvider).positionStream);

final songTitleProvider = Provider<String>((ref) => 'placeholder title');
final songArtistProvider = Provider<String>((ref) => 'placeholder artist');
