import 'package:flutter/material.dart';

class MusicPlatform {
  final String id;
  final String name;
  final String iconPath;
  final Color brandColor;

  const MusicPlatform({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.brandColor,
  });

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
