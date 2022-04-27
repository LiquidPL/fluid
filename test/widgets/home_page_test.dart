import 'package:fluid/main.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'helpers.dart';

void main() {
  testWidgets('NowPlaying panel slides up from the bottom', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerProvider
              .overrideWithValue(mockPlayerWithNQueueElements(count: 1)),
          songTitleProvider
              .overrideWithValue(const AsyncValue.data('test title')),
          songArtistProvider
              .overrideWithValue(const AsyncValue.data('test artist')),
          positionProvider
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
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerProvider
                .overrideWithValue(mockPlayerWithNQueueElements(count: 1)),
            songTitleProvider
                .overrideWithValue(const AsyncValue.data('test title')),
            songArtistProvider
                .overrideWithValue(const AsyncValue.data('test artist')),
            positionProvider
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
