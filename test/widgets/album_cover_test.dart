import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

enum IsSmallScenario {
  yes(true),
  no(false);

  const IsSmallScenario(this.isSmall);

  final bool isSmall;

  @override
  String toString() {
    return 'isSmall: $isSmall';
  }
}

final ValueVariant<IsSmallScenario> variants =
    ValueVariant<IsSmallScenario>(IsSmallScenario.values.toSet());

void main() {
  testWidgets(
    'golden regular image',
    (tester) async {
      final currentVariant = variants.currentValue!;

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: AlbumCover(
            isSmall: currentVariant.isSmall,
            image: Image.asset('test/assets/test_cover.png'),
          ),
        ),
      ));

      await precacheTestAlbumCover(tester);

      await expectLater(
        find.byType(AlbumCover),
        matchesGoldenFile(
          'goldens/album_cover_isSmall_${currentVariant.isSmall}.png',
        ),
      );
    },
    variant: variants,
  );

  testWidgets(
    'golden placeholder image',
    (tester) async {
      final currentVariant = variants.currentValue!;

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: AlbumCover(isSmall: currentVariant.isSmall),
        ),
      ));

      await precachePlaceholderAlbumCover(tester);

      await expectLater(
        find.byType(AlbumCover),
        matchesGoldenFile(
          'goldens/album_cover_no_image_isSmall_${currentVariant.isSmall}.png',
        ),
      );
    },
    variant: variants,
  );
}
