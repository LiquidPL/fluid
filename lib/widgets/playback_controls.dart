import 'package:fluid/providers/playback_state.dart';
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

AnimationController _usePlayPauseButtonAnimationController(WidgetRef ref) {
  final AnimationController controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: ref.read(isPlayingProvider) ? 1.0 : 0.0,
  );

  ref.listen<bool>(isPlayingProvider, ((previous, next) {
    if (next) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }));

  return controller;
}

void _onPlayPauseButtonPressed(WidgetRef ref) {
  ref.read(isPlayingProvider.notifier).update((state) => !state);
}
