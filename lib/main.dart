import 'package:dynamic_color/dynamic_color.dart';
import 'package:fluid/constants.dart';
import 'package:fluid/pages/home_page.dart';
import 'package:fluid/providers/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  /// [databasePathProvider] needs to be awaited here so that it's initialized
  /// on the container, so that it's available for the database provider when
  /// it's first read
  final container = ProviderContainer();
  await container.read(databasePathProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FluidApp(),
    ),
  );
}

class FluidApp extends StatelessWidget {
  const FluidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme =
              lightDynamic.harmonized().copyWith(secondary: Colors.blue);

          darkColorScheme =
              darkDynamic.harmonized().copyWith(secondary: Colors.blue);
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: Constants.appName,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
