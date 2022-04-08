import 'package:fluid/player.dart';
import 'package:fluid/providers/playback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum PlaybackStates {
  playing,
  paused,
}

final ValueVariant<PlaybackStates> stateVariants =
    ValueVariant<PlaybackStates>(PlaybackStates.values.toSet());

void main() {
  testWidgets(
    'play/pause button changes state when tapped',
    (tester) async {
      final isPlaying = stateVariants.currentValue == PlaybackStates.playing;
      final finalAnimationProgress =
          stateVariants.currentValue == PlaybackStates.playing ? 0.0 : 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPlayingProvider.overrideWithValue(StateController(isPlaying))
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Controls(),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedIcon &&
            widget.icon == AnimatedIcons.play_pause &&
            widget.progress.value == finalAnimationProgress),
        findsOneWidget,
      );
    },
    variant: stateVariants,
  );

  testWidgets(
    'golden play/pause button state',
    (tester) async {
      final isPlaying = stateVariants.currentValue == PlaybackStates.playing;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPlayingProvider.overrideWithValue(StateController(isPlaying))
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const Scaffold(
              body: Controls(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Controls),
        matchesGoldenFile(
          'goldens/controls_${stateVariants.currentValue.toString()}.png',
        ),
      );
    },
    variant: stateVariants,
  );
}
