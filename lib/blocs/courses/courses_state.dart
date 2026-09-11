part of 'courses_cubit.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any fetch has been triggered.
class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

/// Fetch in progress.
class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

/// Courses loaded successfully for [grade].
class CoursesLoaded extends CoursesState {
  const CoursesLoaded({required this.courses, required this.grade});

  final List<CourseModel> courses;
  final String grade;

  @override
  List<Object?> get props => [courses, grade];
}

/// An error occurred while fetching courses.
class CoursesError extends CoursesState {
  const CoursesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
