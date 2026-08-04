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

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? '',
      lessons: ((json['lessons'] as List?) ?? const [])
          .map((e) => CourseLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      questions: ((json['questions'] as List?) ?? const [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CourseLesson {
  final String title;
  final String content;

  const CourseLesson({required this.title, required this.content});

  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}
