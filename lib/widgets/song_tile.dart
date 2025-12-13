import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';

class SongTile extends StatelessWidget {
  final AppSong song;
  final VoidCallback onTap;

  const SongTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _art(),
      title: Text(
        song.title,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () => _openMenu(context),
      ),
      onTap: onTap,
    );
  }

  Widget _art() {
    final art = song.albumArt;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF282828),
      ),
      child: art != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(File(art), fit: BoxFit.cover),
            )
          : const Icon(Icons.music_note, color: Colors.grey),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202020),
      builder: (ctx) {
        final playlistProvider = ctx.watch<PlaylistProvider>();
        final lists = playlistProvider.playlists;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.white),
                  title: const Text('Add to playlist',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPlaylist(context);
                  },
                ),
                if (lists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: Text(
                      'No playlist yet. Create one in Playlists screen.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202020),
      builder: (ctx) {
        final playlistProvider = ctx.watch<PlaylistProvider>();
        final playlists = playlistProvider.playlists;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Choose playlist',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const Divider(color: Colors.white12, height: 1),
                ...playlists.map((p) {
                  final inList = playlistProvider.containsSong(p.id, song.id);
                  return ListTile(
                    title: Text(p.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${p.songIds.length} songs',
                        style: const TextStyle(color: Colors.grey)),
                    trailing: Icon(inList ? Icons.check : Icons.add,
                        color: inList ? Colors.greenAccent : Colors.white),
                    onTap: () async {
                      if (!inList) {
                        await context
                            .read<PlaylistProvider>()
                            .addSongToPlaylist(p.id, song.id);
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(inList
                                ? 'Already in playlist'
                                : 'Added to ${p.name}')),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
