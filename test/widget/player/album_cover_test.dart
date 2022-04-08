import 'package:fluid/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('golden', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: AlbumCover(),
      ),
    ));

    await expectLater(
      find.byType(AlbumCover),
      matchesGoldenFile('goldens/album_cover_no_image.png'),
    );
  });
}
