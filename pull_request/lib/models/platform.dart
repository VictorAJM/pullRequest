class Platform {
  final String id;
  final String name;
  final String iconPath;

  const Platform({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Platform &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          iconPath == other.iconPath;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ iconPath.hashCode;

  @override
  String toString() => 'Platform(id: $id, name: $name, iconPath: $iconPath)';
}
