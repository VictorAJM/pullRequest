import '../models/playlist.dart';
import '../models/transfer_progress.dart';

/// Abstract contract for transferring playlists between music platforms.
///
/// Concrete implementations:
///   - MockTransferService  — simulates transfer with delays (current)
///   - RealTransferService  — calls source + destination APIs (planned)
abstract class TransferRepository {
  /// Transfers [playlists] from [sourcePlatformId] to [destinationPlatformId].
  ///
  /// Yields [TransferProgress] updates as each song is processed.
  /// The stream completes when all playlists have been handled.
  /// Throws [TransferException] on unrecoverable errors.
  Stream<TransferProgress> transferPlaylists(
    List<Playlist> playlists,
    String sourcePlatformId,
    String destinationPlatformId,
  );

  /// Signals the implementation to stop the in-flight transfer.
  Future<void> cancelTransfer();
}
