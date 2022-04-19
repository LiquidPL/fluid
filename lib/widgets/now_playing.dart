import 'package:fluid/helpers.dart';
import 'package:fluid/providers/audio_player.dart';
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

    return Material(
      child: SafeArea(
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
                      margin: isPortrait
                          ? const EdgeInsets.only(bottom: 32.0)
                          : null,
                      child: const _ProgressBar(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            ref
                .watch(songTitleProvider)
                .maybeWhen(data: (value) => value, orElse: () => ''),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          ref
              .watch(songArtistProvider)
              .maybeWhen(data: (value) => value, orElse: () => ''),
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
    final double duration = ref.watch(durationProvider).maybeWhen(
          data: (data) => data != null ? data.inMilliseconds / 1000 : 0,
          orElse: () => 0,
        );

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
                      formatDuration(ref.watch(progressProvider).value),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      formatDuration(ref.watch(durationProvider).value),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                )),
            Slider(
              min: 0,
              max: duration,
              value: ref.watch(progressProvider).maybeWhen(
                    data: (data) {
                      final double position =
                          data != null ? data.inMilliseconds / 1000 : 0;

                      // handling edge case where the audio player reports
                      // position that's higher than the audio file duration
                      return position < duration ? position : duration;
                    },
                    orElse: () => 0,
                  ),
              onChanged: (newProgress) {
                ref.read(audioPlayerProvider).seek(
                    Duration(microseconds: (newProgress * 1000000).floor()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
