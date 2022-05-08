import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/playback_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../test/helpers.dart';
import '../../test/widgets/playback_controls_test.dart';

void main() {
  group('PlayPauseButton', () {
    testWidgets(
      'playing state changes when pressed',
      (tester) async {
        final isPlaying = stateVariants.currentValue == PlaybackStates.playing;

        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(player),
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

        await player.setAudioSource(createListOfSources(1));

        if (isPlaying) {
          player.play();
        } else {
          await player.stop();
        }
        await tester.pumpAndSettle();

        expect(player.playing, isPlaying);

        await tester.tap(find.byType(PlayPauseFloatingActionButton));
        await tester.pumpAndSettle();

        expect(player.playing, !isPlaying);

        await tester.tap(find.byType(PlayPauseFloatingActionButton));
        await tester.pumpAndSettle();

        expect(player.playing, isPlaying);

        await tester.pumpAndSettle();

        await tester.tap(find.byType(PlayPauseIconButton));
        await tester.pumpAndSettle();

        expect(player.playing, !isPlaying);
      },
      variant: stateVariants,
    );
  });

  group('SkipNextButton', () {
    testWidgets(
      'is enabled when not at the end of the queue',
      (tester) async {
        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipNextButton(),
            ),
          ),
        ));

        await player.setAudioSource(createListOfSources(2));
        await player.seek(Duration.zero, index: 0);

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
        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipNextButton(),
            ),
          ),
        ));

        await player.setAudioSource(createListOfSources(2));
        await player.seek(Duration.zero, index: 1);

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
      'is disabled when the queue is not initialized',
      (tester) async {
        await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkipNextButton(),
            ),
          ),
        ));

        final buttonFinder = find.descendant(
          of: find.byType(SkipNextButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );

    testWidgets(
      'skips to next song when pressed',
      (tester) async {
        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipNextButton(),
            ),
          ),
        ));

        await player.setAudioSource(createListOfSources(2));
        await player.seek(Duration.zero, index: 0);

        await tester.pumpAndSettle();

        await tester.tap(find.byType(SkipNextButton));
        await tester.pumpAndSettle();

        expect(player.sequenceState!.currentIndex, 1);
      },
    );
  });

  group('SkipPreviousButton', () {
    testWidgets(
      'is enabled when not at the beginning of the queue',
      (tester) async {
        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipPreviousButton(),
            ),
          ),
        ));

        await player.setAudioSource(createListOfSources(2));
        await player.seek(Duration.zero, index: 1);

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
        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipPreviousButton(),
            ),
          ),
        ));

        await player.setAudioSource(createListOfSources(2));
        await player.seek(Duration.zero, index: 0);

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
      'is disabled when the queue is not initialized',
      (tester) async {
        await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkipPreviousButton(),
            ),
          ),
        ));

        final buttonFinder = find.descendant(
          of: find.byType(SkipPreviousButton),
          matching: find.byType(IconButton),
        );

        expect(buttonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(buttonFinder).onPressed, isNull);
      },
    );

    testWidgets(
      'skips to previous song when pressed',
      (tester) async {
        final player = AudioPlayer();
        addTearDown(player.dispose);

        await tester.pumpWidget(ProviderScope(
          overrides: [
            audioPlayerProvider.overrideWithValue(player),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SkipPreviousButton(),
            ),
          ),
        ));

        await player.setAudioSource(createListOfSources(2));
        await player.seek(Duration.zero, index: 1);

        await tester.pumpAndSettle();

        await tester.tap(find.byType(SkipPreviousButton));
        await tester.pumpAndSettle();

        expect(player.sequenceState!.currentIndex, 0);
      },
    );
  });
}
