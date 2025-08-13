import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/enums.dart';

import 'package:lingolearn/utilities/enums.dart';

class LessonData {
  final int id;
  final String title;
  final String description;
  final LessonType type;

  bool isCompleted;
  bool isCurrent;

  LessonData(
    this.id,
    this.title,
    this.description,
    this.type,
    this.isCompleted,
    this.isCurrent,
  );

  LessonData copyWith({
    int? id,
    String? title,
    String? description,
    LessonType? type,
    bool? isCompleted,
    bool? isCurrent,
  }) {
    return LessonData(
      id ?? this.id,
      title ?? this.title,
      description ?? this.description,
      type ?? this.type,
      isCompleted ?? this.isCompleted,
      isCurrent ?? this.isCurrent,
    );
  }
}

class UnitData {
  final int id;
  final String title;
  final String description;
  final Color color;
  final int startIndex;
  final int lessonCount;

  UnitData(this.id, this.title, this.description, this.color, this.startIndex,
      this.lessonCount);
}

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
