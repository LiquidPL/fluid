import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

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
