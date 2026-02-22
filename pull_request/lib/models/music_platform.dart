import 'package:flutter/material.dart';

class MusicPlatform {
  final String id;
  final String name;
  final String iconPath;
  final Color brandColor;

  /// OAuth client ID — null until credentials are configured for this platform.
  final String? oauthClientId;

  /// OAuth permission scopes required for playlist access.
  final List<String> scopes;

  const MusicPlatform({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.brandColor,
    this.oauthClientId,
    this.scopes = const [],
  });

  /// Equality is based solely on [id] — two platforms with the same ID
  /// are considered the same regardless of any other field.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicPlatform &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MusicPlatform(id: $id, name: $name)';
}
