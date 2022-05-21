import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../helpers.dart';
import 'audio_player_test.mocks.dart';

@GenerateMocks([AudioPlayer, SequenceState])
void main() {
  group('durationProvider', () {
    test(
      'returns a valid duration',
      () async {
        final player = MockAudioPlayer();
        const duration = Duration(minutes: 1, seconds: 30);

        when(player.durationStream).thenAnswer((_) => Stream.value(duration));

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(durationProvider, (_, AsyncValue<Duration?> next) {
          expect(next.value, const Duration(minutes: 1, seconds: 30));
        });

        verify(player.durationStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );
  });

  group('positionProvider', () {
    test(
      'returns a valid duration',
      () async {
        final player = MockAudioPlayer();
        const position = Duration(seconds: 30);

        when(player.positionStream).thenAnswer((_) => Stream.value(position));

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(positionProvider, (_, AsyncValue<Duration?> next) {
          expect(next.value, const Duration(seconds: 30));
        });

        verify(player.positionStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );
  });

  group('songTitleProvider', () {
    test(
      'returns a valid title',
      () async {
        const audioFile = AudioFile(
          uri: 'content://media/external/audio/media/727',
          title: 'test title',
          artist: 'test artist',
          duration: Duration(minutes: 1),
        );

        final player = MockAudioPlayer();
        final sequenceState = MockSequenceState();

        when(sequenceState.currentSource).thenReturn(audioFile.asAudioSource);
        when(player.sequenceStateStream)
            .thenAnswer((_) => Stream.value(sequenceState));

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(songTitleProvider, (_, AsyncValue<String> next) {
          expect(next.value, 'test title');
        });

        verify(player.sequenceStateStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );

    test(
      'returns an empty string when there are no songs in the queue',
      () async {
        final player = MockAudioPlayer();

        when(player.sequenceStateStream).thenAnswer((_) => Stream.value(null));

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(songTitleProvider, (_, AsyncValue<String> next) {
          expect(next.value, '');
        });

        verify(player.sequenceStateStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );
  });

  group('songArtistProvider', () {
    test(
      'returns a valid artist name',
      () async {
        const audioFile = AudioFile(
          uri: 'content://media/external/audio/media/727',
          title: 'test title',
          artist: 'test artist',
          duration: Duration(minutes: 1),
        );

        final player = MockAudioPlayer();
        final sequenceState = MockSequenceState();

        when(sequenceState.currentSource).thenReturn(audioFile.asAudioSource);
        when(player.sequenceStateStream)
            .thenAnswer((_) => Stream.value(sequenceState));

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(songArtistProvider, (_, AsyncValue<String> next) {
          expect(next.value, 'test artist');
        });

        verify(player.sequenceStateStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );

    test(
      'returns an empty string when there are no songs in the queue',
      () async {
        final player = MockAudioPlayer();

        when(player.sequenceStateStream).thenAnswer((_) => Stream.value(null));

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(songArtistProvider, (_, AsyncValue<String> next) {
          expect(next.value, '');
        });

        verify(player.sequenceStateStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );
  });

  group('currentQueueIndexProvider', () {
    test(
      'returns a correct queue index',
      () async {
        final player = mockPlayerWithNQueueElements(count: 4, currentIndex: 2);

        final container = ProviderContainer(
          overrides: [audioPlayerProvider.overrideWithValue(player)],
        );
        addTearDown(container.dispose);

        container.listen(currentQueueIndexProvider, (_, AsyncValue<int?> next) {
          expect(next.value, 2);
        });

        verify(player.sequenceStateStream).called(1);
        verifyNoMoreInteractions(player);
      },
    );

    test('returns null if there is no ', () async {
      final player = MockAudioPlayer();

      final container = ProviderContainer(
        overrides: [audioPlayerProvider.overrideWithValue(player)],
      );
      addTearDown(container.dispose);

      container.listen(currentQueueIndexProvider, (_, AsyncValue<int?> next) {
        expect(next.value, isNull);
      });
    });
  });
}
