class Playlist {
  final String id;
  final String name;
  final String? description;
  final int trackCount;
  final String? imageUrl;
  final String platformId;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.trackCount,
    this.imageUrl,
    required this.platformId,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      trackCount: json['trackCount'] as int,
      imageUrl: json['imageUrl'] as String?,
      platformId: json['platformId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'trackCount': trackCount,
      'imageUrl': imageUrl,
      'platformId': platformId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          trackCount == other.trackCount &&
          imageUrl == other.imageUrl &&
          platformId == other.platformId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      trackCount.hashCode ^
      imageUrl.hashCode ^
      platformId.hashCode;

  @override
  String toString() =>
      'Playlist(id: $id, name: $name, trackCount: $trackCount, platformId: $platformId)';
}
