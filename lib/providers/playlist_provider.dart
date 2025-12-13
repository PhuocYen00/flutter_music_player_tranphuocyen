import 'package:flutter/foundation.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storage;
  List<PlaylistModel> _playlists = [];
  List<String> _recentIds = [];

  PlaylistProvider(this._storage) {
    _init();
  }

  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);
  List<String> get recentIds => List.unmodifiable(_recentIds);

  Future<void> _init() async {
    _playlists = await _storage.getPlaylists();
    _recentIds = await _storage.getRecentSongIds();
    notifyListeners();
  }

  Future<void> refresh() async {
    _playlists = await _storage.getPlaylists();
    _recentIds = await _storage.getRecentSongIds();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final now = DateTime.now();
    final p = PlaylistModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      songIds: const [],
      createdAt: now,
      updatedAt: now,
    );
    _playlists = [p, ..._playlists];
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final name = newName.trim();
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(name: name, updatedAt: DateTime.now());
    }).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists = _playlists.where((p) => p.id != playlistId).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      final ids = [...p.songIds];
      if (!ids.contains(songId)) ids.add(songId);
      return p.copyWith(songIds: ids, updatedAt: DateTime.now());
    }).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      final ids = [...p.songIds]..remove(songId);
      return p.copyWith(songIds: ids, updatedAt: DateTime.now());
    }).toList();
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  bool containsSong(String playlistId, String songId) {
    final p = _playlists.where((e) => e.id == playlistId).toList();
    if (p.isEmpty) return false;
    return p.first.songIds.contains(songId);
  }

  List<AppSong> resolveSongs(PlaylistModel playlist, List<AppSong> allSongs) {
    final map = {for (final s in allSongs) s.id: s};
    return playlist.songIds.map((id) => map[id]).whereType<AppSong>().toList();
  }

  List<AppSong> resolveRecentSongs(List<AppSong> allSongs) {
    final map = {for (final s in allSongs) s.id: s};
    return _recentIds.map((id) => map[id]).whereType<AppSong>().toList();
  }
}
