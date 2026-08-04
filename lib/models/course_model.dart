import 'question_model.dart';

class Course {
  final int? id;
  final String title;
  final String description;
  final String iconKey;
  final List<CourseLesson> lessons;
  final List<Question> questions;

  const Course({
    this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.lessons,
    required this.questions,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: (json['id'] as num?)?.toInt(),
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'iconKey': iconKey,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}
