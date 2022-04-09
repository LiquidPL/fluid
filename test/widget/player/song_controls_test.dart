import 'package:fluid/now_playing.dart';
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
              body: SongControls(),
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
    'play/pause button updates when playing state is changed elsewhere',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPlayingProvider.overrideWithValue(StateController(false)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  SongControls(key: Key('SongControls1')),
                  SongControls(key: Key('SongControls2')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedIcon &&
            widget.icon == AnimatedIcons.play_pause &&
            widget.progress.value == 0.0),
        findsNWidgets(2),
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('SongControls2')),
          matching: find.byType(FloatingActionButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedIcon &&
            widget.icon == AnimatedIcons.play_pause &&
            widget.progress.value == 1.0),
        findsNWidgets(2),
      );
    },
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
              body: SongControls(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(SongControls),
        matchesGoldenFile(
          'goldens/controls_${stateVariants.currentValue.toString()}.png',
        ),
      );
    },
    variant: stateVariants,
  );
}
