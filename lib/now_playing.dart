import 'package:fluid/helpers.dart';
import 'package:fluid/providers/playback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: const [
              AlbumCover(),
              SongDetails(
                title: 'placeholder song',
                artist: 'placeholder artist',
              ),
            ],
          ),
          const Controls(),
          Container(
            margin: const EdgeInsets.only(bottom: 32.0),
            child: const ProgressBar(),
          ),
        ],
      ),
    );
  }
}

class AlbumCover extends StatelessWidget {
  const AlbumCover({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SvgPicture.asset(
            'assets/placeholder-album-cover.svg',
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}

class SongDetails extends StatelessWidget {
  const SongDetails({
    required this.title,
    required this.artist,
    Key? key,
  }) : super(key: key);

  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            artist,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Controls extends HookConsumerWidget {
  const Controls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    if (ref.read(isPlayingProvider)) {
      controller.forward(from: 1.0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                progress: CurvedAnimation(
                  parent: controller,
                  curve: Curves.easeInOut,
                ),
              ),
              onPressed: () {
                if (ref.read(isPlayingProvider)) {
                  controller.reverse();
                } else {
                  controller.forward();
                }

                ref.read(isPlayingProvider.notifier).update((state) => !state);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends ConsumerWidget {
  const ProgressBar({Key? key}) : super(key: key);

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
                ref.read(progressProvider.notifier).update((state) => newProgress);
              },
            ),
          ],
        ),
      ),
    );
  }
}
