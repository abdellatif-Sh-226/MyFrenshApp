class Mistake {
  final String word;
  final String meaning;
  final String wrongAnswer;
  final int unitNumber;
  final DateTime timestamp;

  const Mistake({
    required this.word,
    required this.meaning,
    required this.wrongAnswer,
    required this.unitNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'wrong': wrongAnswer,
      'unit': unitNumber,
      'ts': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'word': word,
      'meaning': meaning,
      'wrongAnswer': wrongAnswer,
      'unitNumber': unitNumber,
    };
  }

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      word: json['word'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      wrongAnswer: (json['wrongAnswer'] ?? json['wrong'] ?? '') as String,
      unitNumber: (json['unitNumber'] ?? json['unit'] ?? 0) as int,
      timestamp: DateTime.tryParse(
              (json['timestamp'] ?? json['ts'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}
