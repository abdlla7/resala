import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the enrolment / progress state of a course for a student.
enum CourseStatus {
  inProgress,
  notStarted,
  locked,
}

/// Domain model for a single course / subject.
///
/// Intentionally free of Firestore types so the repository layer can swap
/// from mock data to a real Firestore query without touching widgets.
class CourseModel extends Equatable {
  final String id;
  final String title;
  final String description;

  /// Standardised grade key matching [UserEntity.academicGrade],
  /// e.g. `'3rd_secondary'`, `'1st_prep'`.
  final String grade;

  final double progress;          // 0.0 – 1.0
  final CourseStatus status;
  final int totalLessons;
  final int completedLessons;
  final IconData subjectIcon;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.grade,
    required this.progress,
    required this.status,
    required this.totalLessons,
    required this.completedLessons,
    this.subjectIcon = Icons.menu_book,
  });

  @override
  List<Object?> get props => [id, grade, progress, status];
}
