import 'package:fluid/main.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  testWidgets('NowPlaying panel slides up from the bottom', (tester) async {
    final player = MockAudioPlayer();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerProvider.overrideWithValue(player),
          songTitleProvider
              .overrideWithValue(const AsyncValue.data('test title')),
          songArtistProvider
              .overrideWithValue(const AsyncValue.data('test artist')),
          progressProvider
              .overrideWithValue(const AsyncValue.data(Duration.zero)),
          durationProvider
              .overrideWithValue(const AsyncValue.data(Duration.zero)),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.drag(find.byType(MiniPlayer), const Offset(0, -500));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/HomePage_now_playing_open.png'),
    );
  });

  testWidgets(
    'NowPlaying panel slides up when MiniPlayer is tapped',
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
            progressProvider
                .overrideWithValue(const AsyncValue.data(Duration.zero)),
            durationProvider
                .overrideWithValue(const AsyncValue.data(Duration.zero)),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.tap(find.byType(MiniPlayer));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomePage),
        matchesGoldenFile('goldens/HomePage_now_playing_open.png'),
      );
    },
  );
}
