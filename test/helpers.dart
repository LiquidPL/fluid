import 'dart:async';
import 'dart:io';

import 'package:fluid/models/audio_file.dart';
import 'package:fluid/providers/audio_player.dart';
import 'package:fluid/widgets/album_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

///
/// Loads and caches the SVG image displayed as the album cover placeholder.
/// This is necessary since the image is loaded asynchronously during runtime,
/// and will not show up on golden tests as the image will not be loaded
/// by the time the screenshot is taken.
///
Future<void> precachePlaceholderAlbumCover(WidgetTester tester) async {
  await tester.runAsync(() async {
    await precachePicture(
      ExactAssetPicture(
        SvgPicture.svgStringDecoderBuilder,
        'assets/placeholder-album-cover.svg',
      ),
      tester.element(find.byType(AlbumCover)),
    );
  });

  await tester.pumpAndSettle();
}

///
/// Loads and caches the test image displayed as the album cover.
/// This is necessary since the image is loaded asynchronously during runtime,
/// and will not show up on golden tests as the image will not be loaded
/// by the time the screenshot is taken.
///
Future<void> precacheTestAlbumCover(WidgetTester tester) async {
  await tester.runAsync(() async {
    await precacheImage(
      const ExactAssetImage('test/assets/test_cover.png'),
      tester.element(find.byType(AlbumCover)),
    );
  });

  await tester.pumpAndSettle();
}

class FakeAudioPlayer extends Fake implements AudioPlayer {
  List<IndexedAudioSource> _sequence = [];
  int? _currentIndex;
  Duration _position = Duration.zero;
  bool _playing = false;

  final _sequenceController = BehaviorSubject<List<IndexedAudioSource>>();

  final _sequenceStateController = BehaviorSubject<SequenceState?>();

  final _durationController = BehaviorSubject<Duration?>();

  final _positionController = BehaviorSubject<Duration>();

  final _playingController = BehaviorSubject<bool>();

  final _currentIndexController = BehaviorSubject<int?>();

  @override
  List<IndexedAudioSource>? get sequence => _sequence;

  @override
  Stream<List<IndexedAudioSource>?> get sequenceStream =>
      _sequenceController.stream.asBroadcastStream();

  @override
  SequenceState? get sequenceState => _currentIndex != null
      ? SequenceState(
          _sequence,
          _currentIndex!,
          _sequence.asMap().keys.toList(),
          false,
          LoopMode.off,
        )
      : null;

  @override
  Stream<SequenceState?> get sequenceStateStream =>
      _sequenceStateController.stream.asBroadcastStream();

  @override
  Duration? get duration =>
      sequenceState != null && sequenceState!.currentSource != null
          ? sequenceState!.currentSource!.tag.duration
          : null;

  @override
  Stream<Duration?> get durationStream =>
      _durationController.stream.asBroadcastStream();

  @override
  Duration get position => _position;

  @override
  Stream<Duration> get positionStream =>
      _positionController.stream.asBroadcastStream();

  @override
  bool get playing => _playing;

  @override
  Stream<bool> get playingStream =>
      _playingController.stream.asBroadcastStream();

  @override
  int? get currentIndex => _currentIndex;

  @override
  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  @override
  Future<void> dispose() async {
    await _sequenceController.close();
    await _sequenceStateController.close();
    await _durationController.close();
    await _positionController.close();
    await _playingController.close();
    await _currentIndexController.close();
  }

  void _updateSequence() => _sequenceController.add(_sequence);

  void _updateSequenceState() => _sequenceStateController.add(sequenceState);

  void _updateDuration() => _durationController.add(duration);

  void _updatePosition() => _positionController.add(position);

  void _updatePlaying() => _playingController.add(playing);

  void _updateCurrentIndex() => _currentIndexController.add(_currentIndex);

  @override
  Future<Duration?> setAudioSource(AudioSource source,
      {bool preload = true,
      int? initialIndex,
      Duration? initialPosition}) async {
    if (source is! ConcatenatingAudioSource) {
      throw UnimplementedError();
    }
    _sequence = source.children.map((source) {
      if (source is! ProgressiveAudioSource || source.tag is! AudioFile) {
        throw UnimplementedError();
      }

      return (source.tag as AudioFile).asAudioSource;
    }).toList();

    if (_sequence.isNotEmpty) {
      _currentIndex = initialIndex ?? 0;
      _position = initialPosition ?? Duration.zero;
    }

    _updateSequence();
    _updateSequenceState();
    _updateDuration();
    _updatePosition();
    _updateCurrentIndex();

    return Future.value(null);
  }

  @override
  Future<void> seek(Duration? position, {int? index}) {
    _position = position ?? _position;
    _currentIndex = index ?? _currentIndex;

    _updateSequenceState();
    _updateDuration();
    _updatePosition();
    _updateCurrentIndex();

    return Future.value(null);
  }

  @override
  Future<void> seekToNext() {
    if (currentIndex == null || currentIndex == _sequence.length - 1) {
      return Future.value(null);
    }

    return seek(Duration.zero, index: currentIndex! + 1);
  }

  @override
  Future<void> seekToPrevious() {
    if (currentIndex == null || currentIndex == 0) {
      return Future.value(null);
    }

    return seek(Duration.zero, index: currentIndex! - 1);
  }

  @override
  Future<void> play() {
    _playing = true;
    _updatePlaying();

    return Future.value(null);
  }

  @override
  Future<void> pause() {
    _playing = false;
    _updatePlaying();

    return Future.value(null);
  }
}

final fakeAudioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = FakeAudioPlayer();

  player.setAudioSource(ref.read(playlistProvider));

  sleep(const Duration(milliseconds: 500));

  return player;
});

List<AudioModel> createListOfAudioModels(int count) {
  return List<AudioModel>.generate(
    count,
    (index) => AudioModel({
      '_id': index,
      '_uri': 'asset:///integration_test/assets/silence_1m40s.ogg',
      'title': 'song $index',
      'artist': 'test artist',
      'duration': (const Duration(seconds: 100)).inMilliseconds,
    }),
  );
}

List<AudioFile> createListOfAudioFiles(int count) =>
    createListOfAudioModels(count)
        .map((model) => AudioFile.fromAudioModel(model))
        .toList();

ConcatenatingAudioSource createAudioSource({required int childrenCount}) {
  return ConcatenatingAudioSource(
    children: createListOfAudioFiles(childrenCount)
        .map((audioFile) => audioFile.asAudioSource)
        .toList(),
  );
}
