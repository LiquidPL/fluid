import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/playback_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

ConcatenatingAudioSource _createListOfSources(int count) {
  return ConcatenatingAudioSource(
    children: List<IndexedAudioSource>.generate(
      count,
      (_) => AudioSource.uri(
          Uri.parse('asset:///integration_test/assets/silence_1m40s.ogg')),
    ),
  );
}

void main() {
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

        await player.setAudioSource(_createListOfSources(2));
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

        await player.setAudioSource(_createListOfSources(2));
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

        await player.setAudioSource(_createListOfSources(2));
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

        await player.setAudioSource(_createListOfSources(2));
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
  });
}
