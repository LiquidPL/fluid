import 'package:fluid/providers/playback_state.dart';
import 'package:fluid/widgets/playback_controls.dart';
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
  Finder findIcon(bool isPlaying) {
    return find.byWidgetPredicate((widget) =>
        widget is AnimatedIcon &&
        widget.icon == AnimatedIcons.play_pause &&
        widget.progress.value == (isPlaying ? 1.0 : 0.0));
  }

  group('PlayPause buttons', () {
    testWidgets(
      'play/pause button changes state when tapped',
      (tester) async {
        final isPlaying = stateVariants.currentValue == PlaybackStates.playing;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              isPlayingProvider.overrideWithValue(StateController(isPlaying))
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Row(
                  children: const [
                    PlayPauseFloatingActionButton(),
                    PlayPauseIconButton(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PlayPauseFloatingActionButton));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(PlayPauseFloatingActionButton),
            matching: findIcon(!isPlaying),
          ),
          findsOneWidget,
        );

        await tester.tap(find.byType(PlayPauseFloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PlayPauseIconButton));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
              of: find.byType(PlayPauseIconButton),
              matching: findIcon(!isPlaying)),
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
                body: Row(
                  children: const [
                    PlayPauseFloatingActionButton(),
                    PlayPauseIconButton(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PlayPauseFloatingActionButton));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(PlayPauseIconButton),
            matching: findIcon(true),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'golden playing state',
      (tester) async {
        final isPlaying = stateVariants.currentValue == PlaybackStates.playing;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              isPlayingProvider.overrideWithValue(StateController(isPlaying))
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              home: Scaffold(
                body: Row(
                  children: const [
                    PlayPauseFloatingActionButton(),
                    PlayPauseIconButton(),
                  ],
                ),
              ),
            ),
          ),
        );

        final variantName =
            stateVariants.describeValue(stateVariants.currentValue!);

        await expectLater(
          find.byType(PlayPauseFloatingActionButton),
          matchesGoldenFile(
            'goldens/PlayPause_buttons_$variantName.png',
          ),
        );
      },
      variant: stateVariants,
    );
  });
}
