class TransferProgress {
  final String playlistId;
  final String playlistName;
  final String? currentSongTitle;
  final int totalSongs;
  final int transferredSongs;
  final TransferStatus status;
  final String? errorMessage;

  const TransferProgress({
    required this.playlistId,
    required this.playlistName,
    this.currentSongTitle,
    required this.totalSongs,
    required this.transferredSongs,
    required this.status,
    this.errorMessage,
  });

  double get progress {
    if (totalSongs == 0) return 0.0;
    return transferredSongs / totalSongs;
  }

  /// A sentinel used to explicitly pass [null] through [copyWith].
  static const _absent = Object();

  TransferProgress copyWith({
    String? playlistId,
    String? playlistName,
    Object? currentSongTitle = _absent,
    int? totalSongs,
    int? transferredSongs,
    TransferStatus? status,
    Object? errorMessage = _absent,
  }) {
    return TransferProgress(
      playlistId: playlistId ?? this.playlistId,
      playlistName: playlistName ?? this.playlistName,
      currentSongTitle: currentSongTitle == _absent
          ? this.currentSongTitle
          : currentSongTitle as String?,
      totalSongs: totalSongs ?? this.totalSongs,
      transferredSongs: transferredSongs ?? this.transferredSongs,
      status: status ?? this.status,
      errorMessage: errorMessage == _absent
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

enum TransferStatus { pending, inProgress, completed, failed, cancelled }
