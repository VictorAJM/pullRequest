class Song {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      imageUrl: thumbnail is Map ? thumbnail['url'] as String? : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
