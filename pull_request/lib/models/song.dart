class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final int durationSeconds;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.durationSeconds,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      durationSeconds: json['durationSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationSeconds': durationSeconds,
    };
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          album == other.album &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      artist.hashCode ^
      album.hashCode ^
      durationSeconds.hashCode;

  @override
  String toString() =>
      'Song(id: $id, title: $title, artist: $artist, duration: $formattedDuration)';
}
