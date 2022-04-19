import 'package:dynamic_color/dynamic_color.dart';
import 'package:fluid/constants.dart';
import 'package:fluid/models/audio_metadata.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: FluidApp()));
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

PanelController _controller = PanelController();

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  static const platform = MethodChannel('fluid.liquid.pw');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SlidingUpPanel(
      panel: const NowPlaying(),
      collapsed: MiniPlayer(
        onTap: () => _controller.open(),
      ),
      controller: _controller,
      minHeight: 80.0,
      maxHeight: MediaQuery.of(context).size.height,
      body: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('start'),
                onPressed: () async {
                  if (await Permission.storage.status.isDenied) {
                    await Permission.storage.request();
                  }

                  List<Map> songsRaw =
                      await platform.invokeListMethod('getAudioFiles') ?? [];

                  final List<AudioMetadata> songs = [];

                  for (var song in songsRaw) {
                    songs.add(AudioMetadata(
                      title: song['title'],
                      artist: song['artist'],
                      uri: song['uri'],
                      duration: Duration(milliseconds: song['duration']),
                    ));
                  }

                  await ref.read(playerQueueProvider.notifier).addAll(songs);

                  await ref.read(audioPlayerProvider).play();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
