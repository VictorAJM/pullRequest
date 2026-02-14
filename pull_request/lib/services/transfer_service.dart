import 'dart:async';
import '../models/playlist.dart';
import '../models/transfer_progress.dart';

class TransferService {
  // Simulates transferring playlists from source to destination
  Stream<TransferProgress> transferPlaylists(
    List<Playlist> playlists,
    String sourcePlatformId,
    String destinationPlatformId,
  ) async* {
    for (final playlist in playlists) {
      // Start transfer for this playlist
      yield TransferProgress(
        playlistId: playlist.id,
        playlistName: playlist.name,
        totalSongs: playlist.songs.length,
        transferredSongs: 0,
        status: TransferStatus.inProgress,
      );

      // Simulate transferring each song
      for (int i = 0; i < playlist.songs.length; i++) {
        final song = playlist.songs[i];

        // Simulate transfer delay
        await Future.delayed(const Duration(milliseconds: 800));

        // Update progress
        yield TransferProgress(
          playlistId: playlist.id,
          playlistName: playlist.name,
          currentSongTitle: song.title,
          totalSongs: playlist.songs.length,
          transferredSongs: i + 1,
          status: TransferStatus.inProgress,
        );
      }

      // Mark playlist as completed
      yield TransferProgress(
        playlistId: playlist.id,
        playlistName: playlist.name,
        totalSongs: playlist.songs.length,
        transferredSongs: playlist.songs.length,
        status: TransferStatus.completed,
      );

      // Small delay between playlists
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}
