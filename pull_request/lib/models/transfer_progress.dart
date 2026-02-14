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

  TransferProgress copyWith({
    String? playlistId,
    String? playlistName,
    String? currentSongTitle,
    int? totalSongs,
    int? transferredSongs,
    TransferStatus? status,
    String? errorMessage,
  }) {
    return TransferProgress(
      playlistId: playlistId ?? this.playlistId,
      playlistName: playlistName ?? this.playlistName,
      currentSongTitle: currentSongTitle ?? this.currentSongTitle,
      totalSongs: totalSongs ?? this.totalSongs,
      transferredSongs: transferredSongs ?? this.transferredSongs,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum TransferStatus { pending, inProgress, completed, failed, cancelled }
