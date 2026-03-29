import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final int itemCount;
  final String? imageUrl;
  final String platformId;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.title,
    required this.itemCount,
    this.imageUrl,
    required this.platformId,
    this.songs = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    return Playlist(
      id: json['id'] as String,
      title: json['title'] as String,
      itemCount: json['itemCount'] as int? ?? 0,
      imageUrl: thumbnail is Map ? thumbnail['url'] as String? : null,
      platformId: json['platform'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          platformId == other.platformId;

  @override
  int get hashCode => id.hashCode ^ platformId.hashCode;

  @override
  String toString() =>
      'Playlist(id: $id, title: $title, platformId: $platformId)';
}
