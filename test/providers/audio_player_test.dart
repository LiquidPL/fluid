import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../helpers.dart';

final _audioFile = AudioFile(
  uri: 'content://media/external/audio/media/727',
  title: 'test title',
  artist: 'test artist',
  duration: const Duration(minutes: 1, seconds: 30),
);

final _audioSource = ConcatenatingAudioSource(
  children: [_audioFile.asAudioSource],
);

enum IsPlayingScenario {
  yes(true),
  no(false);

  const IsPlayingScenario(this.isPlaying);

  final bool isPlaying;
}

void main() {
  group('durationProvider', () {
    test(
      'returns the duration of the currently playing song',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(_audioSource);

        await container.read(durationProvider.future);

        expect(
          container.read(durationProvider).value,
          const Duration(minutes: 1, seconds: 30),
        );
      },
    );
  });

  group('positionProvider', () {
    test(
      'returns the current position of the audio player',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(
          _audioSource,
          initialPosition: const Duration(seconds: 30),
        );

        await container.read(positionProvider.future);

        expect(
          container.read(positionProvider).value,
          const Duration(seconds: 30),
        );
      },
    );

    test(
      'returns a correct position after seeking',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(_audioSource);

        await container.read(positionProvider.future);

        expect(
          container.read(positionProvider).value,
          const Duration(seconds: 0),
        );

        await player.seek(const Duration(seconds: 10));

        await container.read(positionProvider.future);

        expect(
          container.read(positionProvider).value,
          const Duration(seconds: 10),
        );
      },
    );
  });

  group('isPlayingProvider', () {
    test(
      'returns true if the player is currently playing',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(_audioSource);
        player.play();

        await container.read(isPlayingProvider.future);

        expect(container.read(isPlayingProvider).value, isTrue);
      },
    );

    test(
      'returns false if the player is not currently playing',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(_audioSource);
        player.pause();

        await container.read(isPlayingProvider.future);

        expect(container.read(isPlayingProvider).value, isFalse);
      },
    );
  });

  group('songTitleProvider', () {
    test(
      'returns the title of the currently playing song',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(_audioSource);

        await container.read(songTitleProvider.future);

        expect(
          container.read(songTitleProvider).value,
          'test title',
        );
      },
    );

    test(
      'returns an empty string when there are no songs in the queue',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(ConcatenatingAudioSource(children: []));

        await container.read(songTitleProvider.future);
        expect(container.read(songTitleProvider).value, '');
      },
    );
  });

  group('songArtistProvider', () {
    test(
      'returns the artist of the currently playing song',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(_audioSource);

        await container.read(songArtistProvider.future);

        expect(
          container.read(songArtistProvider).value,
          'test artist',
        );
      },
    );

    test(
      'returns an empty string when there are no songs in the queue',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(ConcatenatingAudioSource(children: []));

        await container.read(songArtistProvider.future);
        expect(container.read(songArtistProvider).value, '');
      },
    );
  });

  group('currentQueueIndexProvider', () {
    test(
      'returns the index of the currently playing song in the queue list',
      () async {
        // final player = mockPlayerWithNQueueElements(count: 4, currentIndex: 2);
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(
          createAudioSource(childrenCount: 3),
          initialIndex: 2,
        );

        await container.read(currentQueueIndexProvider.future);
        expect(container.read(currentQueueIndexProvider).value, 2);
      },
    );

    test(
      'returns null if there is no song playing at the moment',
      () async {
        final player = FakeAudioPlayer();
        addTearDown(player.dispose);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        await player.setAudioSource(ConcatenatingAudioSource(children: []));

        await container.read(currentQueueIndexProvider.future);
        expect(container.read(currentQueueIndexProvider).value, isNull);
      },
    );
  });
}
