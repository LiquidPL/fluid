import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:fluid/widgets/now_playing_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../helpers.dart';

enum ProgressBarPositions {
  start(0.0),
  middle(0.5),
  end(1.0);

  const ProgressBarPositions(this.position);

  final double position;
}

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
              songTitleProvider
                  .overrideWithValue(const AsyncValue.data('test title')),
              songArtistProvider
                  .overrideWithValue(const AsyncValue.data('test artist')),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
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
              audioPlayerProvider.overrideWithProvider(fakeAudioPlayerProvider),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );

        final player = container.read(audioPlayerProvider);
        await player.setAudioSource(
          ConcatenatingAudioSource(
            children: [
              AudioFile(
                id: 727,
                uri: 'content://media/external/audio/media/727',
                title: 'test title',
                artist: 'test artist',
                duration: const Duration(minutes: 1, seconds: 30),
              ).asAudioSource
            ],
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
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
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
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
      'progress bar is present',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
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
        final currentVariant = positionVariants.currentValue!;

        const duration = Duration(hours: 2);
        final position = duration * currentVariant.position;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              audioPlayerProvider.overrideWithProvider(fakeAudioPlayerProvider),
              durationProvider
                  .overrideWithValue(const AsyncValue.data(duration)),
              positionProvider.overrideWithValue(AsyncValue.data(position)),
              songTitleProvider
                  .overrideWithValue(const AsyncValue.data('test title')),
              songArtistProvider
                  .overrideWithValue(const AsyncValue.data('test artist')),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
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

        final variantName = positionVariants.describeValue(currentVariant);

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

  group('NowPlayingQueue', () {
    testWidgets(
      'queue slides up from open player queue panel at the bottom',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await tester.drag(
          find.text('OPEN PLAYER QUEUE'),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        final finder = find.byType(SlidingUpPanel);
        expect(finder, findsOneWidget);

        expect(
          tester.firstWidget<SlidingUpPanel>(finder).controller?.isPanelOpen,
          isTrue,
        );
      },
    );

    testWidgets(
      'queue slides up when the open player queue button is tapped',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('OPEN PLAYER QUEUE'));
        await tester.pumpAndSettle();

        final finder = find.byType(SlidingUpPanel);
        expect(finder, findsOneWidget);

        expect(
          tester.firstWidget<SlidingUpPanel>(finder).controller?.isPanelOpen,
          isTrue,
        );
      },
    );

    testWidgets(
      'queue slides up when the open player queue panel is tapped',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await tester.tapAt(
          tester.getTopLeft(find.byKey(const Key('showPlayerQueuePanel'))),
        );
        await tester.pumpAndSettle();

        final finder = find.byType(SlidingUpPanel);
        expect(finder, findsOneWidget);

        expect(
          tester.firstWidget<SlidingUpPanel>(finder).controller?.isPanelOpen,
          isTrue,
        );
      },
    );

    testWidgets(
      'queue closes when tapped on the arrow button',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: NowPlaying(),
              ),
            ),
          ),
        );

        await tester.tapAt(
          tester.getTopLeft(find.byKey(const Key('showPlayerQueuePanel'))),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(NowPlayingQueue),
            matching: find.byType(IconButton),
          ),
        );
        await tester.pumpAndSettle();

        final finder = find.byType(SlidingUpPanel);
        expect(finder, findsOneWidget);

        expect(
          tester.firstWidget<SlidingUpPanel>(finder).controller?.isPanelOpen,
          isFalse,
        );
      },
    );
  });
}
