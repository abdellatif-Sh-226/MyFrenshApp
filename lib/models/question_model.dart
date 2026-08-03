class Question {
  final String word;
  final List<String> choices;
  final String answer;
  final String meaning;
  final String example;
  final String arabicTranslation;

  const Question({
    required this.word,
    required this.choices,
    required this.answer,
    this.meaning = '',
    this.example = '',
    this.arabicTranslation = '',
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final word = json['word'] as String;
    final answer = json['answer'] as String;
    final normalizedMeaning = json['meaning'] as String? ?? 'Le mot "$word" signifie "$answer".';
    final normalizedExample = json['example'] as String? ?? 'Exemple: $word -> $answer';
    final normalizedArabic = json['arabicTranslation'] as String? ?? answer;

    return Question(
      word: word,
      choices: List<String>.from(json['choices'] as List),
      answer: answer,
      meaning: normalizedMeaning,
      example: normalizedExample,
      arabicTranslation: normalizedArabic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'choices': choices,
      'answer': answer,
      'meaning': meaning,
      'example': example,
      'arabicTranslation': arabicTranslation,
    };
  }
}
