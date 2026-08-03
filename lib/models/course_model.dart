import 'question_model.dart';

class Course {
  final String title;
  final String description;
  final String iconKey;
  final List<CourseLesson> lessons;
  final List<Question> questions;

  const Course({
    required this.title,
    required this.description,
    required this.iconKey,
    required this.lessons,
    required this.questions,
  });
}

class CourseLesson {
  final String title;
  final String content;

  const CourseLesson({required this.title, required this.content});
}
