import 'package:fluid/providers/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayPauseFloatingActionButton extends HookConsumerWidget {
  const PlayPauseFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = _usePlayPauseButtonAnimationController(ref);

    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        progress: CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      ),
      onPressed: () => _onPlayPauseButtonPressed(ref),
    );
  }
}

class PlayPauseIconButton extends HookConsumerWidget {
  const PlayPauseIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = _usePlayPauseButtonAnimationController(ref);

    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      ),
      onPressed: () => _onPlayPauseButtonPressed(ref),
    );
  }
}

final _nextButtonEnabled = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerProvider).sequenceStateStream.map(
      (sequenceState) =>
          (sequenceState != null && sequenceState.sequence.isNotEmpty)
              ? sequenceState.currentIndex < sequenceState.sequence.length - 1
              : false);
});

final _previousButtonEnabled = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerProvider).sequenceStateStream.map(
      (sequenceState) =>
          sequenceState != null ? sequenceState.currentIndex > 0 : false);
});

class SkipNextButton extends ConsumerWidget {
  const SkipNextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed: ref.watch(_nextButtonEnabled).value ?? false
          ? () async => ref.read(audioPlayerProvider).seekToNext()
          : null,
    );
  }
}

class SkipPreviousButton extends ConsumerWidget {
  const SkipPreviousButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: ref.watch(_previousButtonEnabled).value ?? false
          ? () async => ref.read(audioPlayerProvider).seekToPrevious()
          : null,
    );
  }
}

AnimationController _usePlayPauseButtonAnimationController(WidgetRef ref) {
  final AnimationController controller = useAnimationController(
    duration: const Duration(milliseconds: 500),
    initialValue: ref.read(isPlayingProvider).maybeWhen(
          data: (isPlaying) => isPlaying ? 1.0 : 0.0,
          orElse: () => 0.0,
        ),
  );

  ref.watch(isPlayingProvider).whenData((isPlaying) {
    if (isPlaying) {
      controller.forward();
    } else {
      controller.reverse();
    }
  });
  return controller;
}

void _onPlayPauseButtonPressed(WidgetRef ref) {
  final player = ref.read(audioPlayerProvider);

  ref.read(isPlayingProvider).whenData((isPlaying) {
    if (isPlaying) {
      player.pause();
    } else {
      player.play();
    }
  });
}
