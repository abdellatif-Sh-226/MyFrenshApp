class Story {
  final int? id;
  final String title;
  final String content;
  final List<StoryQuestion> questions;

  const Story({
    this.id,
    required this.title,
    required this.content,
    required this.questions,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      questions: ((json['questions'] as List?) ?? const [])
          .map((e) => StoryQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class StoryQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  const StoryQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory StoryQuestion.fromJson(Map<String, dynamic> json) {
    return StoryQuestion(
      question: json['question'] as String? ?? '',
      options: ((json['options'] as List?) ?? const []).cast<String>(),
      correctAnswer: json['correctAnswer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
