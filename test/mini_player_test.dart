import 'package:fluid/providers/playback_state.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets(
    'song title and artist are displayed correctly',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            songTitleProvider.overrideWithValue('test title'),
            songArtistProvider.overrideWithValue('test artist')
          ],
          child: const MaterialApp(
              home: Scaffold(
            body: MiniPlayer(),
          )),
        ),
      );

      expect(find.text('test title'), findsOneWidget);
      expect(find.text('test artist'), findsOneWidget);
    },
  );

  testWidgets(
    'golden',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            songTitleProvider.overrideWithValue('test title'),
            songArtistProvider.overrideWithValue('test artist')
          ],
          child: const MaterialApp(
              home: Scaffold(
            body: MiniPlayer(),
          )),
        ),
      );

      await tester.runAsync(() async {
        precachePicture(
          ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder,
            'assets/placeholder-album-cover.svg',
          ),
          tester.element(find.byType(MiniPlayer)),
        );
      });

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MiniPlayer),
        matchesGoldenFile('goldens/MiniPlayer.png'),
      );
    },
  );
}
