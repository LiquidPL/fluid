import 'package:fluid/providers/media_store.dart';
import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/database.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/mini_player.dart';
import 'package:fluid/widgets/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulHookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
      body: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async =>
                    await ref.read(mediaStoreProvider).scan(),
                child: const Text('rescan'),
              ),
              TextButton(
                onPressed: () async {
                  final database = ref.read(databaseProvider);

                  final audioFiles =
                      await database.audioFiles.where().findAll();

                  await ref
                      .read(playerQueueProvider.notifier)
                      .addAll(audioFiles);
                  await ref.read(audioPlayerProvider).play();
                },
                child: const Text('play'),
              )
            ],
          ),
        ),
      ),
      key: const Key('nowPlayingPanel'),
    );
  }
}
