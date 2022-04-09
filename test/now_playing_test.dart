import 'package:fluid/providers/playback_state.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ProgressBarPositions { start, middle, end }

final ValueVariant<ProgressBarPositions> positionVariants =
    ValueVariant<ProgressBarPositions>(ProgressBarPositions.values.toSet());

void main() {
  group('song details', () {
    testWidgets(
      'title and artist labels are displayed',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              songTitleProvider.overrideWithValue('test title'),
              songArtistProvider.overrideWithValue('test artist'),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
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
              songArtistProvider.overrideWithValue('test artist'),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(NowPlaying),
          matchesGoldenFile('goldens/NowPlaying_song_details.png'),
        );
      },
    );
  });

  group('progress bar', () {
    testWidgets(
      'song duration is displayed correctly',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [durationProvider.overrideWithValue(127)],
            child: const MaterialApp(
              home: Scaffold(
                body: NowPlaying(),
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
                body: NowPlaying(),
              ),
            ),
          ),
        );

        expect(find.text('0:50'), findsOneWidget);
        expect(find.text('1:40'), findsOneWidget);
      },
    );

    testWidgets(
      'progress bar is displayed correctly',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        expect(find.byType(Slider), findsOneWidget);
      },
    );

    testWidgets(
      'dragging progress bar updates progress label',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: NowPlaying(),
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
              progressProvider.overrideWithValue(
                  StateController(progressValues[currentVariant] as double)),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              home: const Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await tester.runAsync(() async {
          precachePicture(
            ExactAssetPicture(
              SvgPicture.svgStringDecoderBuilder,
              'assets/placeholder-album-cover.svg',
            ),
            tester.element(find.byType(NowPlaying)),
          );
        });

        await tester.pumpAndSettle();

        final variantName = positionVariants.describeValue(currentVariant!);

        await expectLater(
          find.byType(NowPlaying),
          matchesGoldenFile(
            'goldens/NowPlaying_progress_bar_$variantName.png',
          ),
        );
      },
      variant: positionVariants,
    );
  });
}
