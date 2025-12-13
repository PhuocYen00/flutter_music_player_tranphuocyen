class PlaybackStateModel {
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  PlaybackStateModel({
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  double get progress {
    final totalMs = duration.inMilliseconds;
    if (totalMs <= 0) return 0.0;
    return position.inMilliseconds / totalMs;
  }
}
