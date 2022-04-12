String formatDuration(Duration? duration) {
  if (duration == null) {
    return '0:00';
  }

  var hours = duration.inHours > 0 ? "${duration.inHours}:" : '';
  var minutes = duration.inMinutes.remainder(60).toString();
  var seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  if (duration.inHours > 0) {
    minutes = minutes.padLeft(2, '0');
  }

  return "$hours$minutes:$seconds";
}
