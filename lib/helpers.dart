String formatDuration(double duration) {
  var dur = Duration(seconds: duration.floor());

  var hours = dur.inHours > 0 ? dur.inHours.toString() + ':' : '';
  var minutes = dur.inMinutes.remainder(60).toString();
  var seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');

  if (dur.inHours > 0) {
    minutes = minutes.padLeft(2, '0');
  }

  return "$hours$minutes:$seconds";
}
