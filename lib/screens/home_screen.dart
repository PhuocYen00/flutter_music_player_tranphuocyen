import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<AppSong> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  LibrarySort _sort = LibrarySort.title;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final granted = await _permissionService.requestMusicPermission();

    if (granted) {
      await _loadSongs();
    }

    setState(() {
      _hasPermission = granted;
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs(sort: _sort);
      if (!mounted) {
        return;
      }
      setState(() => _songs = songs);
      await context.read<AudioProvider>().restoreLastSession(_songs);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải nhạc: $e')),
      );
    }
  }

  List<AppSong> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _songs;
    return _songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          (s.album?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearch(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasPermission
                      ? _buildPermissionDenied()
                      : _filtered.isEmpty
                          ? _buildNoSongs()
                          : _buildSongList(),
            ),
            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null) {
                  return const SizedBox.shrink();
                }
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Nhạc của tôi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<LibrarySort>(
              value: _sort,
              dropdownColor: const Color(0xFF282828),
              iconEnabledColor: Colors.white,
              items: const [
                DropdownMenuItem(
                  value: LibrarySort.title,
                  child: Text('Tên bài'),
                ),
                DropdownMenuItem(
                  value: LibrarySort.artist,
                  child: Text('Ca sĩ'),
                ),
                DropdownMenuItem(
                  value: LibrarySort.album,
                  child: Text('Album'),
                ),
                DropdownMenuItem(
                  value: LibrarySort.dateAdded,
                  child: Text('Ngày thêm'),
                ),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() {
                  _sort = v;
                  _isLoading = true;
                });
                await _loadSongs();
                if (!mounted) {
                  return;
                }
                setState(() => _isLoading = false);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaylistScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm bài hát, ca sĩ, album...',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF282828),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) => setState(() => _query = v),
      ),
    );
  }

  Widget _buildSongList() {
    final list = _filtered;
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final song = list[index];
        return SongTile(
          song: song,
          onTap: () {
            final realIndex = _songs.indexWhere((s) => s.id == song.id);
            context.read<AudioProvider>().setPlaylist(
                  _songs,
                  realIndex < 0 ? 0 : realIndex,
                );
          },
        );
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Cần cấp quyền',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vui lòng cấp quyền để ứng dụng truy cập nhạc trên thiết bị.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _permissionService.openSettings(),
              child: const Text('Mở cài đặt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSongs() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Không tìm thấy nhạc',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Hãy thêm một vài file nhạc vào thiết bị.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
