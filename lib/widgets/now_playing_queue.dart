import 'package:fluid/helpers.dart';
import 'package:fluid/models/audio_metadata.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/providers/player_queue.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NowPlayingQueue extends ConsumerWidget {
  const NowPlayingQueue({
    required this.scrollController,
    this.panelController,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
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
                metadata: queue[index],
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
    required this.metadata,
    required this.queueIndex,
    Key? key,
  }) : super(key: key);

  final AudioMetadata metadata;
  final int queueIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(metadata.title),
      subtitle: Text(
        '${metadata.artist} • ${formatDuration(metadata.duration)}',
      ),
      leading: const AlbumCover(),
      trailing: Text((queueIndex + 1).toString()),
      selected: ref.watch(currentQueueIndexProvider).value == queueIndex,
      tileColor: Theme.of(context).colorScheme.surface,
      onTap: () async {
        await ref.read(audioPlayerProvider).seek(
              Duration.zero,
              index: queueIndex,
            );

        await ref.read(audioPlayerProvider).play();
      },
    );
  }
}
