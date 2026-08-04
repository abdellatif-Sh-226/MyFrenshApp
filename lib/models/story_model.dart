class Story {
  final String title;
  final String content;
  final List<StoryQuestion> questions;

  const Story({
    required this.title,
    required this.content,
    required this.questions,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      questions: ((json['questions'] as List?) ?? const [])
          .map((e) => StoryQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
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
}
