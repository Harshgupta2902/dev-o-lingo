import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/enums.dart';

class LessonData {
  final int id;
  final String title;
  final String description;
  final LessonType type;
  final bool isCompleted;
  final bool isCurrent;

  LessonData(this.id, this.title, this.description, this.type, this.isCompleted,
      this.isCurrent);
}

class UnitData {
  final int id;
  final String title;
  final String description;
  final Color color;
  final int startIndex; // Index of the first lesson in this unit (0-based)
  final int lessonCount;

  UnitData(this.id, this.title, this.description, this.color, this.startIndex,
      this.lessonCount);
}

class PathItem {
  final String type; // 'lesson' or 'unit'
  final dynamic data; // LessonData or UnitData
  final int pathIndex; // Overall index in the combined path

  PathItem({required this.type, required this.data, required this.pathIndex});
}