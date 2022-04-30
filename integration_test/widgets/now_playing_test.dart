import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  testWidgets(
    'dragging progress bar updates progress label',
    (tester) async {
      final player = AudioPlayer();
      addTearDown(player.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerProvider
                .overrideWithProvider(Provider<AudioPlayer>((ref) => player)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NowPlaying(),
            ),
          ),
        ),
      );

      await player.setAsset('integration_test/assets/silence_1m40s.ogg');
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(FocusableActionDetector),
        const Offset(5000, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('1:40'), findsNWidgets(2));

      await tester.drag(
        find.byType(FocusableActionDetector),
        const Offset(-5000, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);
      expect(find.text('1:40'), findsOneWidget);

      player.dispose();
    },
  );
}
