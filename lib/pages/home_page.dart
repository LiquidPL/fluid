import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PanelController panelController;

  static const _miniPlayerHeight = 70.0;

  @override
  void initState() {
    super.initState();

    panelController = PanelController();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: const NowPlaying(),
      collapsed: MiniPlayer(
        height: _miniPlayerHeight,
        onTap: () => panelController.open(),
      ),
      controller: panelController,
      minHeight: _miniPlayerHeight,
      maxHeight: MediaQuery.of(context).size.height,
      boxShadow: const [],
      body: const Scaffold(
        body: _StartButton(),
      ),
      key: const Key('nowPlayingPanel'),
    );
  }
}

class _StartButton extends ConsumerWidget {
  const _StartButton({Key? key}) : super(key: key);

  static const platform = MethodChannel('fluid.liquid.pw');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: const Text('start'),
            onPressed: () async {
              if (await Permission.storage.status.isDenied) {
                await Permission.storage.request();
              }

              List<Map> filesRaw =
                  await platform.invokeListMethod('getAudioFiles') ?? [];

              final List<AudioFile> audioFiles = [];

              for (var file in filesRaw) {
                audioFiles.add(AudioFile(
                  title: file['title'],
                  artist: file['artist'],
                  uri: file['uri'],
                  duration: Duration(milliseconds: file['duration']),
                ));
              }

              await ref.read(playerQueueProvider.notifier).addAll(audioFiles);

              await ref.read(audioPlayerProvider).play();
            },
          ),
        ],
      ),
    );
  }
}
