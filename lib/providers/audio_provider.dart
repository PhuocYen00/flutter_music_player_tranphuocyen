import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playback_state_model.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  final Random _random = Random();

  List<AppSong> _playlist = [];
  int _currentIndex = 0;

  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  double get volume => _audioService.volume;
  double get speed => _audioService.speed;

  StreamSubscription<PlayerState>? _playerStateSub;
  bool _handlingComplete = false;

  AudioProvider(this._audioService, this._storageService) {
    _init();
  }

  List<AppSong> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  AppSong? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackStateModel> get playbackStateStream =>
      _audioService.playbackStateStream;

  bool get isPlaying => _audioService.isPlaying;

  Future<void> _init() async {
    await _audioService.configureAudioSession();

    _isShuffleEnabled = await _storageService.getShuffleState();

    final repeatMode = await _storageService.getRepeatMode();
    _loopMode = _intToLoopMode(repeatMode);
    await _audioService.setLoopMode(_loopMode);

    final volume = await _storageService.getVolume();
    await _audioService.setVolume(volume);

    _playerStateSub ??= _audioService.playerStateStream.listen(_onPlayerState);

    notifyListeners();
  }

  Future<void> _onPlayerState(PlayerState state) async {
    if (state.processingState != ProcessingState.completed) return;
    if (_handlingComplete) return;

    _handlingComplete = true;

    try {
      await _storageService.saveLastPositionMs(0);

      if (_playlist.isEmpty) return;

      if (_loopMode == LoopMode.one) {
        await _audioService.seek(Duration.zero);
        await _audioService.play();
        return;
      }

      await next();
    } finally {
      Future.delayed(const Duration(milliseconds: 250), () {
        _handlingComplete = false;
      });
    }
  }

  Future<void> setPlaylist(List<AppSong> songs, int startIndex) async {
    if (songs.isEmpty) return;

    _playlist = songs;
    _currentIndex = startIndex.clamp(0, songs.length - 1);

    await _playSongAtIndex(_currentIndex);
  }

  Future<void> restoreLastSession(List<AppSong> allSongs) async {
    final lastId = await _storageService.getLastPlayed();
    if (lastId == null) return;

    final index = allSongs.indexWhere((s) => s.id == lastId);
    if (index < 0) return;

    _playlist = allSongs;
    _currentIndex = index;

    await _audioService.loadAudio(_playlist[_currentIndex].filePath);

    final posMs = await _storageService.getLastPositionMs();
    if (posMs > 0) {
      await _audioService.seek(Duration(milliseconds: posMs));
    }

    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (_playlist.isEmpty) return;
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;

    final song = _playlist[index];
    await _audioService.loadAudio(song.filePath);
    await _audioService.play();

    await _storageService.saveLastPlayed(song.id);
    await _storageService.saveLastPositionMs(0);

    notifyListeners();
  }

  Future<void> playPause() async {
    if (_playlist.isEmpty) return;

    if (_audioService.isPlaying) {
      await _storageService
          .saveLastPositionMs(_audioService.currentPosition.inMilliseconds);
      await _audioService.pause();
    } else {
      await _audioService.play();
    }

    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    final nextIndex = _isShuffleEnabled
        ? _getRandomIndex(exclude: _currentIndex)
        : _nextIndexByLoopMode();

    await _playSongAtIndex(nextIndex);
  }

  int _nextIndexByLoopMode() {
    final last = _playlist.length - 1;
    if (_currentIndex < last) return _currentIndex + 1;

    if (_loopMode == LoopMode.all) return 0;

    return _currentIndex;
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
      return;
    }

    final prevIndex = _isShuffleEnabled
        ? _getRandomIndex(exclude: _currentIndex)
        : (_currentIndex - 1 + _playlist.length) % _playlist.length;

    await _playSongAtIndex(prevIndex);
  }

  Future<void> seek(Duration position) => _audioService.seek(position);

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }

    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopModeToInt(_loopMode));
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(v);
    await _storageService.saveVolume(v);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed.clamp(0.5, 2.0));
    notifyListeners();
  }

  int _getRandomIndex({int? exclude}) {
    if (_playlist.length <= 1) return 0;

    int idx;
    do {
      idx = _random.nextInt(_playlist.length);
    } while (exclude != null && idx == exclude);

    return idx;
  }

  LoopMode _intToLoopMode(int value) {
    if (value == 1) return LoopMode.all;
    if (value == 2) return LoopMode.one;
    return LoopMode.off;
  }

  int _loopModeToInt(LoopMode mode) {
    if (mode == LoopMode.all) return 1;
    if (mode == LoopMode.one) return 2;
    return 0;
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
