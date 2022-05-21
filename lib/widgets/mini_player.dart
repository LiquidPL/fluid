import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:fluid/widgets/playback_controls.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MiniPlayer extends HookConsumerWidget {
  const MiniPlayer({this.onTap, Key? key}) : super(key: key);

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      elevation: Theme.of(context).navigationBarTheme.elevation ?? 3.0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          height: 70.0,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0)
                    .copyWith(right: 8.0),
                child: const AlbumCover(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        ref.watch(songTitleProvider).maybeWhen(
                            data: (value) => value, orElse: () => ''),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      ref
                          .watch(songArtistProvider)
                          .maybeWhen(data: (value) => value, orElse: () => ''),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const PlayPauseIconButton(),
            ],
          ),
        ),
      ),
    );
  }
}
