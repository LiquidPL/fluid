import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'player_queue_test.mocks.dart';

const _audioFile1 = AudioFile(
  uri: 'content://media/external/audio/media/1',
  title: 'title 1',
  artist: 'artist',
  duration: Duration.zero,
);

const _audioFile2 = AudioFile(
  uri: 'content://media/external/audio/media/2',
  title: 'title 2',
  artist: 'artist',
  duration: Duration.zero,
);

class _IsAudioFile extends Matcher {
  _IsAudioFile(this._audioFile);

  late final AudioFile _audioFile;

  @override
  Description describe(Description description) => description
      .add('\'UriAudioSource\' matching provided \'AudioFile\'')
      .add(': (${_audioFile.uri}, ${_audioFile.title})');

  @override
  bool matches(item, Map matchState) {
    return item is UriAudioSource &&
        item.uri == _audioFile.asAudioSource.uri &&
        item.tag == _audioFile;
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) =>
      super
          .describeMismatch(item, mismatchDescription, matchState, verbose)
          .add('(${item.uri}, ${item.tag.title})');
}

@GenerateMocks([ConcatenatingAudioSource])
void main() {
  test('add() adds items to the queue', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(playerQueueProvider.notifier).add(_audioFile1);

    expect(container.read(playerQueueProvider), [_audioFile1]);

    await container.read(playerQueueProvider.notifier).add(_audioFile2);

    expect(container.read(playerQueueProvider), [_audioFile1, _audioFile2]);
  });

  test('add() updates the player audio source playlist', () async {
    final audioSource = MockConcatenatingAudioSource();

    final container = ProviderContainer(
        overrides: [playlistProvider.overrideWithValue(audioSource)]);
    addTearDown(container.dispose);

    await container.read(playerQueueProvider.notifier).add(_audioFile1);

    verify(await audioSource.add(argThat(_IsAudioFile(_audioFile1)))).called(1);
  });

  test('addAll() adds many items to the queue', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(playerQueueProvider.notifier)
        .addAll([_audioFile1, _audioFile2]);

    expect(container.read(playerQueueProvider), [_audioFile1, _audioFile2]);
  });

  test('addAll() updates the player audio source playlist', () async {
    final audioSource = MockConcatenatingAudioSource();

    final container = ProviderContainer(
        overrides: [playlistProvider.overrideWithValue(audioSource)]);
    addTearDown(container.dispose);

    await container
        .read(playerQueueProvider.notifier)
        .addAll([_audioFile1, _audioFile2]);

    expect(verify(audioSource.addAll(captureAny)).captured.single,
        [_IsAudioFile(_audioFile1), _IsAudioFile(_audioFile2)]);
  });

  test('clear() removes all items from the queue', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(playerQueueProvider.notifier)
        .addAll([_audioFile1, _audioFile2]);
    await container.read(playerQueueProvider.notifier).clear();

    expect(container.read(playerQueueProvider), isEmpty);
  });

  test('clear() updates the playlist in the audio player object', () async {
    final audioSource = MockConcatenatingAudioSource();

    final container = ProviderContainer(
        overrides: [playlistProvider.overrideWithValue(audioSource)]);
    addTearDown(container.dispose);

    await container
        .read(playerQueueProvider.notifier)
        .addAll([_audioFile1, _audioFile2]);
    await container.read(playerQueueProvider.notifier).clear();

    verify(audioSource.clear()).called(1);
  });
}
