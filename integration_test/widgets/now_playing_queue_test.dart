import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/now_playing_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../test/helpers.dart';

void main() {
  testWidgets(
    'currently playing song changes when tapping queue list item',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
          .addAll(createListOfAudioMetadata(4));

      await tester.pumpAndSettle();

      for (int i in Iterable.generate(4)) {
        await tester.tap(find.text('song $i'));

        // wait longer to ensure AudioPlayer has begun to play the file
        // this is particularly important since the playback might take longer
        // to start in low-performance scenarios, for instance in CI runners
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(container.read(audioPlayerProvider).currentIndex, i);

        final widget = tester.firstWidget<ListTile>(
          find.ancestor(
            of: find.text('song $i'),
            matching: find.byType(ListTile),
          ),
        );

        expect(widget.selected, isTrue);
      }
    },
  );
}
