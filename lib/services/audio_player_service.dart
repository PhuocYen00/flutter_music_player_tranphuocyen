import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;

  double get volume => _audioPlayer.volume;
  double get speed => _audioPlayer.speed;

  Stream<PlaybackStateModel> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackStateModel>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) => PlaybackStateModel(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> loadAudio(String filePath) => _audioPlayer.setFilePath(filePath);

  Future<void> play() => _audioPlayer.play();
  Future<void> pause() => _audioPlayer.pause();
  Future<void> stop() => _audioPlayer.stop();
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  Future<void> setVolume(double volume) => _audioPlayer.setVolume(volume);
  Future<void> setSpeed(double speed) => _audioPlayer.setSpeed(speed);
  Future<void> setLoopMode(LoopMode loopMode) =>
      _audioPlayer.setLoopMode(loopMode);
  Future<void> loadAsset(String assetPath) async {
    await _audioPlayer.setAsset(assetPath);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
