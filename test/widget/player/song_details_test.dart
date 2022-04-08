import 'package:fluid/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'title and artist labels are displayed',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SongDetails(
          title: 'test title',
          artist: 'test artist',
        ),
      ));

      final titleFinder = find.text('test title');
      final artistFinder = find.text('test artist');

      expect(titleFinder, findsOneWidget);
      expect(artistFinder, findsOneWidget);
    },
  );
  testWidgets(
    'golden',
    (tester) async {
      const key = Key('SongDetails');

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const SongDetails(
          title: 'test title',
          artist: 'test artist',
          key: key,
        ),
      ));

      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/song_details.png'),
      );
    },
  );
}
