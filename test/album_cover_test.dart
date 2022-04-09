import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('golden', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: AlbumCover(),
      ),
    ));

    await tester.runAsync(() async {
      precachePicture(
        ExactAssetPicture(
          SvgPicture.svgStringDecoderBuilder,
          'assets/placeholder-album-cover.svg',
        ),
        tester.element(find.byType(AlbumCover)),
      );
    });

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AlbumCover),
      matchesGoldenFile('goldens/album_cover_no_image.png'),
    );
  });
}
