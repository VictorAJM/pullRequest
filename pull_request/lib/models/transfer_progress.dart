import 'song.dart';

class TransferProgress {
  final String status;
  final int totalItems;
  final int currentItem;
  final String? currentSong;
  final String? currentThumbnail;
  final String? platformFrom;
  final List<Song> failedItems;

  const TransferProgress({
    required this.status,
    this.totalItems = 0,
    this.currentItem = 0,
    this.currentSong,
    this.currentThumbnail,
    this.platformFrom,
    this.failedItems = const [],
  });

  double get progress {
    if (status == 'completed') return 1.0;
    if (totalItems == 0) return 0.0;
    return currentItem / totalItems;
  }

  factory TransferProgress.fromJson(Map<String, dynamic> json) {
    return TransferProgress(
      status: json['status'] as String,
      totalItems: json['totalItems'] as int? ?? 0,
      currentItem: json['currentItem'] as int? ?? 0,
      currentSong: json['current_song'] as String?,
      currentThumbnail: json['current_thumbnail'] as String?,
      platformFrom: json['platformFrom'] as String?,
      failedItems: (json['failedItems'] as List?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
