import '../models/transfer_progress.dart';

/// Abstract contract for transferring a playlist via the backend.
abstract class TransferRepository {
  /// Transfers a single playlist from [sourcePlatformId] to the opposite
  /// platform. The backend determines the destination automatically.
  ///
  /// Yields [TransferProgress] updates via SSE until the transfer
  /// completes or errors.
  Stream<TransferProgress> transferPlaylist(
    String playlistId,
    String sourcePlatformId,
  );

  /// Attaches to an active transfer for the current device and streams progress.
  /// If no transfer is active, it throws or yields nothing.
  Stream<TransferProgress> resumeTransfer();
}
