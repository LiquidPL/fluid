import 'package:fluid/models/duration_converter.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

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

  AudioFile.fromAudioModel(AudioModel model)
      : assert(model.uri != null),
        id = model.id,
        uri = model.uri!,
        title = model.title,
        artist = model.artist ?? '',
        duration = Duration(milliseconds: model.duration ?? 0);

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
