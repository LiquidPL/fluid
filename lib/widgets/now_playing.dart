import 'package:fluid/helpers.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:fluid/widgets/playback_controls.dart';
import 'package:fluid/widgets/now_playing_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NowPlaying extends ConsumerWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return _PlayerQueuePanel(
      body: Material(
        child: SafeArea(
          minimum: !isPortrait
              ? const EdgeInsets.symmetric(horizontal: 16.0) +
                  const EdgeInsets.only(top: 32.0, bottom: 70.0 + 16.0)
              : EdgeInsets.zero,
          child: Flex(
            direction: isPortrait ? Axis.vertical : Axis.horizontal,
            children: [
              Container(
                margin: isPortrait
                    ? const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 8.0)
                    : null,
                child: const AlbumCover(),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 32.0),
                  child: const _SongControls(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerQueuePanel extends StatefulWidget {
  const _PlayerQueuePanel({
    required this.body,
    Key? key,
  }) : super(key: key);

  final Widget body;

  @override
  State<_PlayerQueuePanel> createState() => __PlayerQueuePanelState();
}

class __PlayerQueuePanelState extends State<_PlayerQueuePanel> {
  late final PanelController panelController;

  @override
  void initState() {
    super.initState();

    panelController = PanelController();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panelBuilder: ((scrollController) => NowPlayingQueue(
            scrollController: scrollController,
            panelController: panelController,
          )),
      collapsed: Material(
        color: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        elevation: Theme.of(context).navigationBarTheme.elevation ?? 3.0,
        child: InkWell(
          onTap: _onTapCollapsed,
          child: Center(
            child: TextButton(
              onPressed: _onTapCollapsed,
              key: const Key('showPlayerQueuePanel'),
              child: Text(
                AppLocalizations.of(context)!.playerQueue.toUpperCase(),
              ),
            ),
          ),
        ),
      ),
      controller: panelController,
      minHeight: 70.0,
      maxHeight: MediaQuery.of(context).size.height,
      boxShadow: const [],
      body: widget.body,
    );
  }

  void _onTapCollapsed() => panelController.open();
}

class _SongControls extends StatelessWidget {
  const _SongControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _TitleArtist(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SkipPreviousButton(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const PlayPauseFloatingActionButton(),
            ),
            const SkipNextButton(),
          ],
        ),
        Container(
          margin:
              isPortrait ? const EdgeInsets.only(bottom: 70.0 + 16.0) : null,
          child: const _ProgressBar(),
        ),
      ],
    );
  }
}

class _TitleArtist extends ConsumerWidget {
  const _TitleArtist({Key? key}) : super(key: key);

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

    return SliderTheme(
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
                    formatDuration(ref.watch(positionProvider).value),
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
            value: ref.watch(positionProvider).maybeWhen(
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
    );
  }
}
