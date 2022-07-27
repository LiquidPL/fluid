import 'package:fluid/helpers.dart';
import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NowPlayingQueue extends ConsumerWidget {
  const NowPlayingQueue({
    this.scrollController,
    this.panelController,
    Key? key,
  }) : super(key: key);

  final ScrollController? scrollController;
  final PanelController? panelController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(playerQueueProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            title: Text(AppLocalizations.of(context)!.upNext),
            backgroundColor: Theme.of(context).colorScheme.surface,
            pinned: true,
            leading: panelController != null
                ? IconButton(
                    icon: const Icon(Icons.expand_more),
                    onPressed: () => panelController?.close(),
                  )
                : null,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: queue.length,
              (context, index) => _QueueItem(
                audioFile: queue[index],
                queueIndex: index,
                key: ObjectKey(queue[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueItem extends ConsumerWidget {
  const _QueueItem({
    required this.audioFile,
    required this.queueIndex,
    Key? key,
  }) : super(key: key);

  final AudioFile audioFile;
  final int queueIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworkModel = ref.watch(artworkModelProvider(audioFile.id!)).value;

    return ListTile(
      title: Text(audioFile.title),
      subtitle: Text(
        '${audioFile.artist} • ${formatDuration(audioFile.duration)}',
      ),
      leading: AlbumCover(
        isSmall: true,
        image: artworkModel != null && artworkModel.artwork != null
            ? Image.memory(artworkModel.artwork!)
            : null,
      ),
      trailing: Text((queueIndex + 1).toString()),
      selected: ref.watch(currentQueueIndexProvider).value == queueIndex,
      tileColor: Theme.of(context).colorScheme.surface,
      onTap: () async {
        await ref.read(audioPlayerProvider).seek(
              Duration.zero,
              index: queueIndex,
            );

        ref.read(audioPlayerProvider).play();
      },
    );
  }
}
