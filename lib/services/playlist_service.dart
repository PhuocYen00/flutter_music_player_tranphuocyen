import 'package:on_audio_query_forked/on_audio_query.dart' as oq;
import '../models/song_model.dart';

enum LibrarySort { title, artist, album, dateAdded }

class PlaylistService {
  final oq.OnAudioQuery _audioQuery = oq.OnAudioQuery();

  oq.SongSortType _mapSort(LibrarySort sort) {
    if (sort == LibrarySort.artist) return oq.SongSortType.ARTIST;
    if (sort == LibrarySort.album) return oq.SongSortType.ALBUM;
    if (sort == LibrarySort.dateAdded) return oq.SongSortType.DATE_ADDED;
    return oq.SongSortType.TITLE;
  }

  Future<List<AppSong>> getAllSongs(
      {LibrarySort sort = LibrarySort.title}) async {
    final songs = await _audioQuery.querySongs(
      sortType: _mapSort(sort),
      orderType: oq.OrderType.ASC_OR_SMALLER,
      uriType: oq.UriType.EXTERNAL,
      ignoreCase: true,
    );
    return songs.map((s) => AppSong.fromAudioQuery(s)).toList();
  }

  Future<List<AppSong>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      return allSongs;
    }

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q) ||
          (song.album?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
