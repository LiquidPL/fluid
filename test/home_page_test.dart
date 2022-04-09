import 'package:fluid/main.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('NowPlaying panel slides up from the bottom', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.drag(find.byType(MiniPlayer), const Offset(0, -500));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/HomePage_now_playing_open.png'),
    );
  });
}
