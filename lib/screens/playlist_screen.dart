import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _playlistService = PlaylistService();
  bool _loading = true;
  var _allSongs = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final songs = await _playlistService.getAllSongs();
    if (!mounted) {
      return;
    }
    setState(() {
      _allSongs = songs;
      _loading = false;
    });
    await context.read<PlaylistProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        title: const Text('Danh sách phát'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createDialog(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (provider.recentIds.isNotEmpty) _recentSection(context),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Danh sách của bạn',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (provider.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Text(
                      'Chưa có danh sách phát nào.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ...provider.playlists.map((p) {
                  return ListTile(
                    title: Text(
                      p.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${p.songIds.length} bài hát',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: PopupMenuButton<String>(
                      color: const Color(0xFF202020),
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      onSelected: (v) {
                        if (v == 'rename') {
                          _renameDialog(context, p.id, p.name);
                        }
                        if (v == 'delete') {
                          context.read<PlaylistProvider>().deletePlaylist(p.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                        PopupMenuItem(value: 'delete', child: Text('Xoá')),
                      ],
                    ),
                    onTap: () => _openPlaylist(context, p.id, p.name),
                  );
                }),
              ],
            ),
    );
  }

  Widget _recentSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.white),
      title: const Text(
        'Nghe gần đây',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Chạm để phát lại',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () async {
        final pp = context.read<PlaylistProvider>();
        final recentSongs = pp.resolveRecentSongs(_allSongs.cast());
        if (recentSongs.isEmpty) {
          return;
        }
        await context.read<AudioProvider>().setPlaylist(recentSongs, 0);
      },
    );
  }

  Future<void> _createDialog(BuildContext context) async {
    final c = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tạo danh sách phát'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(hintText: 'Tên danh sách phát'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () async {
                final name = c.text.trim();
                if (name.isEmpty) {
                  return;
                }
                await context.read<PlaylistProvider>().createPlaylist(name);
                if (!ctx.mounted) {
                  return;
                }
                Navigator.pop(ctx);
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameDialog(
    BuildContext context,
    String id,
    String current,
  ) async {
    final c = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Đổi tên danh sách phát'),
          content: TextField(controller: c),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () async {
                final name = c.text.trim();
                if (name.isEmpty) {
                  return;
                }
                await context.read<PlaylistProvider>().renamePlaylist(id, name);
                if (!ctx.mounted) {
                  return;
                }
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _openPlaylist(BuildContext context, String playlistId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaylistSongsScreen(
          playlistId: playlistId,
          title: title,
          allSongs: _allSongs.cast(),
        ),
      ),
    );
  }
}

class _PlaylistSongsScreen extends StatelessWidget {
  final String playlistId;
  final String title;
  final List<dynamic> allSongs;

  const _PlaylistSongsScreen({
    required this.playlistId,
    required this.title,
    required this.allSongs,
  });

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PlaylistProvider>();
    final playlist = pp.playlists.firstWhere((p) => p.id == playlistId);
    final songs = pp.resolveSongs(playlist, allSongs.cast());

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        title: Text(title),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                'Danh sách phát trống',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (_, i) {
                final s = songs[i];
                return ListTile(
                  title: Text(
                    s.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    s.artist,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white70,
                    ),
                    onPressed: () => context
                        .read<PlaylistProvider>()
                        .removeSongFromPlaylist(playlistId, s.id),
                  ),
                  onTap: () =>
                      context.read<AudioProvider>().setPlaylist(songs, i),
                );
              },
            ),
    );
  }
}
