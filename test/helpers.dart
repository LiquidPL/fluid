import 'package:fluid/models/audio_metadata.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'helpers.mocks.dart';

///
/// Loads and caches the SVG image displayed as the album cover placeholder.
/// This is necessary since the image is loaded asynchronously during runtime,
/// and will not show up on golden tests as the image will not be loaded
/// by the time the screenshot is taken.
///
Future<void> precachePlaceholderAlbumCover(WidgetTester tester) async {
  await tester.runAsync(() async {
    await precachePicture(
      ExactAssetPicture(
        SvgPicture.svgStringDecoderBuilder,
        'assets/placeholder-album-cover.svg',
      ),
      tester.element(find.byType(AlbumCover)),
    );
  });

  await tester.pumpAndSettle();
}

@GenerateMocks([AudioPlayer])
MockAudioPlayer mockPlayerWithQueue({
  List<IndexedAudioSource>? sequence,
  int currentIndex = 0,
}) {
  final player = MockAudioPlayer();
  final sequenceState = sequence != null
      ? SequenceState(
          sequence,
          currentIndex,
          sequence.asMap().keys.toList(),
          false,
          LoopMode.off,
        )
      : null;

  when(player.sequenceStream).thenAnswer((_) => Stream.value(sequence));
  when(player.sequence).thenReturn(sequence);

  when(player.sequenceStateStream)
      .thenAnswer((_) => Stream.value(sequenceState));
  when(player.sequenceState).thenReturn(sequenceState);

  return player;
}

MockAudioPlayer mockPlayerWithEmptyQueue() =>
    mockPlayerWithQueue(sequence: [], currentIndex: 0);

MockAudioPlayer mockPlayerWithNullQueue() =>
    mockPlayerWithQueue(sequence: null);

MockAudioPlayer mockPlayerWithNQueueElements({
  required int count,
  int currentIndex = 0,
}) {
  final sequence = List<IndexedAudioSource>.generate(
    count,
    (i) => AudioSource.uri(
      Uri.parse('content://media/external/audio/media/$i'),
    ),
  );

  return mockPlayerWithQueue(sequence: sequence, currentIndex: currentIndex);
}

List<AudioMetadata> createListOfAudioMetadata(int count) {
  return List<AudioMetadata>.generate(
    count,
    (index) => AudioMetadata(
      uri: 'asset:///integration_test/assets/silence_1m40s.ogg',
      title: 'song $index',
      artist: 'test artist',
      duration: const Duration(minutes: 1, seconds: 40),
    ),
  );
}

ConcatenatingAudioSource createListOfSources(int count) {
  return ConcatenatingAudioSource(
    children: createListOfAudioMetadata(count)
        .map((metadata) => metadata.asAudioSource)
        .toList(),
  );
}
