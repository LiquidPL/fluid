import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';

import 'helpers.dart';
import 'now_playing_test.mocks.dart';

enum ProgressBarPositions { start, middle, end }

final ValueVariant<ProgressBarPositions> positionVariants =
    ValueVariant<ProgressBarPositions>(ProgressBarPositions.values.toSet());

@GenerateMocks([AudioPlayer])
void main() {
  group('song details', () {
    testWidgets(
      'title and artist labels are displayed',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              songTitleProvider
                  .overrideWithValue(const AsyncValue.data('test title')),
              songArtistProvider
                  .overrideWithValue(const AsyncValue.data('test artist')),
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
        final player = MockAudioPlayer();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(player),
              positionProvider
                  .overrideWithValue(const AsyncValue.data(Duration.zero)),
              durationProvider
                  .overrideWithValue(const AsyncValue.data(Duration.zero)),
              songTitleProvider
                  .overrideWithValue(const AsyncValue.data('test title')),
              songArtistProvider
                  .overrideWithValue(const AsyncValue.data('test artist')),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await precachePlaceholderAlbumCover(tester);

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
            overrides: [
              durationProvider.overrideWithValue(
                  const AsyncValue.data(Duration(minutes: 2, seconds: 7))),
            ],
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
      'song position is displayed correctly',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              durationProvider.overrideWithValue(
                  const AsyncValue.data(Duration(minutes: 1, seconds: 40))),
              positionProvider.overrideWithValue(
                  const AsyncValue.data(Duration(seconds: 50))),
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
      'golden progress bar position',
      (tester) async {
        final currentVariant = positionVariants.currentValue;

        const duration = Duration(hours: 2);

        final Map<ProgressBarPositions, Duration> positionValues = {
          ProgressBarPositions.start: Duration.zero,
          ProgressBarPositions.middle: duration ~/ 2,
          ProgressBarPositions.end: duration,
        };

        final player = MockAudioPlayer();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithValue(player),
              durationProvider
                  .overrideWithValue(const AsyncValue.data(duration)),
              positionProvider.overrideWithValue(
                  AsyncValue.data(positionValues[currentVariant])),
              songTitleProvider
                  .overrideWithValue(const AsyncValue.data('test title')),
              songArtistProvider
                  .overrideWithValue(const AsyncValue.data('test artist')),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              home: const Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await precachePlaceholderAlbumCover(tester);

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