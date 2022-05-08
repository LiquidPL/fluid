import 'package:fluid/main.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  testWidgets(
    'now playing panel slides up from the MiniPlayer at the bottom',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomePage(),
          ),
        ),
      );

      await tester.drag(find.byType(MiniPlayer), const Offset(0, -500));
      await tester.pumpAndSettle();

      final finder = find.byKey(const Key('nowPlayingPanel'));
      expect(finder, findsOneWidget);

      final panel = tester.firstWidget<SlidingUpPanel>(finder);

      expect(panel.controller?.isPanelOpen, isTrue);
    },
  );

  testWidgets(
    'now playing panel slides up when MiniPlayer is tapped',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomePage(),
          ),
        ),
      );

      await tester.tap(find.byType(MiniPlayer));
      await tester.pumpAndSettle();

      final finder = find.byKey(const Key('nowPlayingPanel'));
      expect(finder, findsOneWidget);

      final panel = tester.firstWidget<SlidingUpPanel>(finder);

      expect(panel.controller?.isPanelOpen, isTrue);
    },
  );
}
