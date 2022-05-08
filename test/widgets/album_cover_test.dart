import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('golden', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: AlbumCover(),
      ),
    ));

    await precachePlaceholderAlbumCover(tester);

    await expectLater(
      find.byType(AlbumCover),
      matchesGoldenFile('goldens/album_cover_no_image.png'),
    );
  });
}
