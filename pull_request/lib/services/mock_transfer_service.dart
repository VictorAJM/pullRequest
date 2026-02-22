import 'dart:async';
import '../models/playlist.dart';
import '../models/transfer_progress.dart';
import '../repositories/transfer_repository.dart';

/// Simulates a playlist transfer by yielding progress events with delays.
///
/// Replace with RealTransferService once the destination platform's
/// write API is available (search track → add to playlist).
/// Only main.dart needs to change.
class MockTransferService implements TransferRepository {
  bool _cancelled = false;

  @override
  Stream<TransferProgress> transferPlaylists(
    List<Playlist> playlists,
    String sourcePlatformId,
    String destinationPlatformId,
  ) async* {
    _cancelled = false;

    for (final playlist in playlists) {
      if (_cancelled) break;

      yield TransferProgress(
        playlistId: playlist.id,
        playlistName: playlist.name,
        totalSongs: playlist.songs.length,
        transferredSongs: 0,
        status: TransferStatus.inProgress,
      );

      for (int i = 0; i < playlist.songs.length; i++) {
        if (_cancelled) break;

        await Future.delayed(const Duration(milliseconds: 800));

        yield TransferProgress(
          playlistId: playlist.id,
          playlistName: playlist.name,
          currentSongTitle: playlist.songs[i].title,
          totalSongs: playlist.songs.length,
          transferredSongs: i + 1,
          status: TransferStatus.inProgress,
        );
      }

      if (!_cancelled) {
        yield TransferProgress(
          playlistId: playlist.id,
          playlistName: playlist.name,
          totalSongs: playlist.songs.length,
          transferredSongs: playlist.songs.length,
          status: TransferStatus.completed,
        );

        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  @override
  Future<void> cancelTransfer() async {
    _cancelled = true;
  }
}
