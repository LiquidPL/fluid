import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/playback_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'helpers.dart';

enum PlaybackStates {
  playing,
  paused,
}

final ValueVariant<PlaybackStates> stateVariants =
    ValueVariant<PlaybackStates>(PlaybackStates.values.toSet());

Finder _findIcon(bool isPlaying) {
  return find.byWidgetPredicate((widget) =>
      widget is AnimatedIcon &&
      widget.icon == AnimatedIcons.play_pause &&
      widget.progress.value == (isPlaying ? 1.0 : 0.0));
}

void main() {
  group('PlayPause buttons', () {
    testWidgets(
      'play/pause button changes state when tapped',
      (tester) async {
        final isPlaying = stateVariants.currentValue == PlaybackStates.playing;

        final player = AudioPlayer();
        addTearDown(player.dispose);
        if (isPlaying) {
          player.play();
        } else {
          player.pause();
        }

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider
                  .overrideWithProvider(Provider<AudioPlayer>((ref) => player)),
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
            matching: _findIcon(!isPlaying),
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
              matching: _findIcon(!isPlaying)),
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

        expect(_findIcon(false), findsNWidgets(2));

        await tester.tap(find.byType(PlayPauseFloatingActionButton));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(PlayPauseIconButton),
            matching: _findIcon(true),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'golden playing state',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              isPlayingProvider.overrideWithValue(AsyncValue.data(
                  stateVariants.currentValue == PlaybackStates.playing)),
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

  group('SkipNextButton', () {
    testWidgets(
      'is enabled when not at the end of the queue',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(
                  mockPlayerWithNQueueElements(count: 2, currentIndex: 0)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SkipNextButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipNextButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNotNull);
      },
    );

    testWidgets(
      'is disabled when at the end of the queue',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(
                  mockPlayerWithNQueueElements(count: 2, currentIndex: 1)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SkipNextButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipNextButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );

    testWidgets(
      'is disabled when the queue is empty',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(mockPlayerWithEmptyQueue()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SkipNextButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipNextButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );

    testWidgets(
      'is disabled when the queue is null',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(mockPlayerWithNullQueue()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SkipNextButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipNextButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );
  });

  group('SkipPreviousButton', () {
    testWidgets(
      'is enabled when not at the beginning of the queue',
      (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(
              mockPlayerWithNQueueElements(count: 2, currentIndex: 1),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipPreviousButton(),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipPreviousButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNotNull);
      },
    );

    testWidgets(
      'is disabled when at the beginning of the queue',
      (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(
              mockPlayerWithNQueueElements(count: 2, currentIndex: 0),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipPreviousButton(),
            ),
          ),
        ));

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipPreviousButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );

    testWidgets(
      'is disabled when the queue is empty',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(mockPlayerWithEmptyQueue()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SkipPreviousButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipPreviousButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );

    testWidgets(
      'is disabled when the queue is null',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(mockPlayerWithNullQueue()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SkipPreviousButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byType(SkipPreviousButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );
  });
}
