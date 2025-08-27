class PathItem {
  final String type;
  final dynamic data;
  final int pathIndex;
  final int? unitIndex;

  PathItem({
    required this.type,
    required this.data,
    required this.pathIndex,
    this.unitIndex,
  });
}
