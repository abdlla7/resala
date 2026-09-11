import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/course_model.dart';
import '../../repositories/courses_repository.dart';

part 'courses_state.dart';

/// Cubit responsible for loading and exposing grade-filtered course lists.
///
/// Feed it the [CoursesRepository] abstraction — swap the mock for a
/// Firestore-backed repository without touching this file.
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit({required CoursesRepository repository})
      : _repository = repository,
        super(const CoursesInitial());

  final CoursesRepository _repository;

  /// Fetch all courses for [grade] (e.g. `'3rd_secondary'`).
  Future<void> loadCoursesByGrade(String grade) async {
    if (grade.isEmpty) return;
    emit(const CoursesLoading());
    try {
      final courses = await _repository.getCoursesByGrade(grade);
      emit(CoursesLoaded(courses: courses, grade: grade));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
