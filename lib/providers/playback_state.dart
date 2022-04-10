import 'package:hooks_riverpod/hooks_riverpod.dart';

final isPlayingProvider = StateProvider<bool>((ref) => false);

// placeholder value until audio player plumbing is connected
final durationProvider = Provider<double>((ref) => 100.0);
final progressProvider = StateProvider<double>((ref) => 0.0);

final songTitleProvider = Provider<String>((ref) => 'placeholder title');
final songArtistProvider = Provider<String>((ref) => 'placeholder artist');
