import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/now_playing_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../helpers.dart';
import 'now_playing_queue_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  testWidgets(
    'currently playing song changes when tapping queue list item',
    (tester) async {
      final player = MockAudioPlayer();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
            currentQueueIndexProvider
                .overrideWithValue(const AsyncValue.data(0)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: NowPlayingQueue(),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      await container
          .read(playerQueueProvider.notifier)
          .addAll(createListOfAudioFiles(4));

      await tester.pumpAndSettle();

      for (int i in Iterable.generate(4)) {
        await tester.tap(find.text('song $i'));
        await tester.pumpAndSettle();

        verify(player.seek(Duration.zero, index: i)).called(1);
      }
    },
  );
}
