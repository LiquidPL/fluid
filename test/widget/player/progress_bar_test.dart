import 'package:fluid/now_playing.dart';
import 'package:fluid/providers/playback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ProgressBarPositions { start, middle, end }

final ValueVariant<ProgressBarPositions> positionVariants =
    ValueVariant<ProgressBarPositions>(ProgressBarPositions.values.toSet());

void main() {
  testWidgets(
    'song duration is displayed correctly',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [durationProvider.overrideWithValue(127)],
          child: const MaterialApp(
            home: Scaffold(
              body: ProgressBar(),
            ),
          ),
        ),
      );

      final progressFinder = find.text('0:00');
      final durationFinder = find.text('2:07');

      expect(progressFinder, findsOneWidget);
      expect(durationFinder, findsOneWidget);
    },
  );

  testWidgets(
    'song progress is displayed correctly',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            durationProvider.overrideWithValue(100),
            progressProvider.overrideWithValue(StateController(50)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProgressBar(),
            ),
          ),
        ),
      );

      final progressFinder = find.text('0:50');
      final durationFinder = find.text('1:40');

      expect(progressFinder, findsOneWidget);
      expect(durationFinder, findsOneWidget);
    },
  );

  testWidgets(
    'dragging progress bar updates progress label',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProgressBar(),
            ),
          ),
        ),
      );

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
    },
  );

  testWidgets(
    'golden progress bar position',
    (tester) async {
      final currentVariant = positionVariants.currentValue;

      const duration = 7200.0;

      final Map<ProgressBarPositions, double> progressValues = {
        ProgressBarPositions.start: 0,
        ProgressBarPositions.middle: duration / 2,
        ProgressBarPositions.end: duration,
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            durationProvider.overrideWithValue(duration),
            progressProvider.overrideWithValue(StateController(progressValues[currentVariant] as double)),
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const Scaffold(
              body: ProgressBar(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ProgressBar),
        matchesGoldenFile(
          'goldens/progress_bar_${positionVariants.currentValue}.png',
        ),
      );
    },
    variant: positionVariants,
  );
}
