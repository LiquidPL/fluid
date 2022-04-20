import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'helpers.dart';
import 'mini_player_test.mocks.dart';

abstract class _OnTap {
  void call();
}

class _OnTapMock extends Mock implements _OnTap {}

@GenerateMocks([AudioPlayer])
void main() {
  testWidgets(
    'song title and artist are displayed correctly',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            songTitleProvider
                .overrideWithValue(const AsyncValue.data('test title')),
            songArtistProvider
                .overrideWithValue(const AsyncValue.data('test artist')),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MiniPlayer(),
            ),
          ),
        ),
      );

      expect(find.text('test title'), findsOneWidget);
      expect(find.text('test artist'), findsOneWidget);
    },
  );

  testWidgets(
    'onTap callback called when tapped',
    (tester) async {
      final onTap = _OnTapMock();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MiniPlayer(
                onTap: onTap,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MiniPlayer));
      await tester.pumpAndSettle();

      verify(onTap()).called(1);
    },
  );

  testWidgets(
    'golden',
    (tester) async {
      final player = MockAudioPlayer();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
            songTitleProvider
                .overrideWithValue(const AsyncValue.data('test title')),
            songArtistProvider
                .overrideWithValue(const AsyncValue.data('test artist')),
          ],
          child: const MaterialApp(
              home: Scaffold(
            body: MiniPlayer(),
          )),
        ),
      );

      await precachePlaceholderAlbumCover(tester);

      await expectLater(
        find.byType(MiniPlayer),
        matchesGoldenFile('goldens/MiniPlayer.png'),
      );
    },
  );
}