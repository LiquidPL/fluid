import 'package:fluid/models/audio_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('asAudioSource returns a valid instance with a valid url', () {
    const metadata = AudioMetadata(
      uri: 'content://media/external/audio/media/727',
      title: 'test title',
      artist: 'test artist',
      duration: Duration(minutes: 1, seconds: 20),
    );

    final audioSource = metadata.asAudioSource;

    expect(
      audioSource.uri.toString(),
      'content://media/external/audio/media/727',
    );

    expect(audioSource.tag, metadata);
  });
}
