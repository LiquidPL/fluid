import 'package:fluid/models/duration_converter.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';

part 'audio_file.g.dart';

@Collection()
class AudioFile {
  AudioFile({
    this.id,
    required this.uri,
    required this.title,
    required this.artist,
    required this.duration,
  });

  @Id()
  int? id;

  @Name('uri')
  final String uri;

  @Name('title')
  final String title;

  @Name('artist')
  final String artist;

  @Name('duration')
  @DurationConverter()
  final Duration duration;

  UriAudioSource get asAudioSource => AudioSource.uri(
        Uri.parse(uri),
        tag: this,
      );
}
