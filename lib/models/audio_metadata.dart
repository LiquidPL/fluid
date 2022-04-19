import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

@immutable
class AudioMetadata {
  const AudioMetadata({
    required this.uri,
    required this.title,
    required this.artist,
    required this.duration,
  });

  final String uri;
  final String title;
  final String artist;
  final Duration duration;

  UriAudioSource get asAudioSource => AudioSource.uri(
        Uri.parse(uri),
        tag: this,
      );
}
