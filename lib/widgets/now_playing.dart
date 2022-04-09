import 'package:fluid/helpers.dart';
import 'package:fluid/providers/playback_state.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:fluid/widgets/playback_controls.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SafeArea(
      minimum: !isPortrait
          ? const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0)
          : EdgeInsets.zero,
      child: Flex(
        direction: isPortrait ? Axis.vertical : Axis.horizontal,
        children: [
          Container(
            margin: isPortrait
                ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0)
                : null,
            child: const AlbumCover(),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _SongDetails(),
                  const PlayPauseFloatingActionButton(),
                  Container(
                    margin:
                        isPortrait ? const EdgeInsets.only(bottom: 32.0) : null,
                    child: const _ProgressBar(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongDetails extends ConsumerWidget {
  const _SongDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            ref.watch(songTitleProvider),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          ref.watch(songArtistProvider),
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SliderTheme(
        data: const SliderThemeData(
          trackHeight: 2.0,
        ),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(ref.watch(progressProvider)),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      formatDuration(ref.watch(durationProvider)),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                )),
            Slider(
              min: 0,
              max: ref.watch(durationProvider),
              value: ref.watch(progressProvider),
              onChanged: (newProgress) {
                ref
                    .read(progressProvider.notifier)
                    .update((state) => newProgress);
              },
            ),
          ],
        ),
      ),
    );
  }
}
