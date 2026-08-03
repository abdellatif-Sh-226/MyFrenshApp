import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../services/json_loader_service.dart';

class QuizProvider extends ChangeNotifier {
  final JsonLoaderService _jsonLoader;

  List<Question> _allQuestions = [];
  List<Question> _shuffledQuestions = [];
  List<List<String>> _shuffledChoices = [];

  int _currentIndex = 0;
  int _score = 0;
  List<bool> _answers = [];
  List<String?> _selectedValues = [];
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _isLoading = true;
  int _unitNumber = 0;

  QuizProvider(this._jsonLoader);

  List<Question> get questions => _shuffledQuestions;
  List<List<String>> get shuffledChoices => _shuffledChoices;
  int get currentIndex => _currentIndex;
  int get score => _score;
  List<bool> get answers => _answers;
  List<String?> get selectedValues => _selectedValues;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get isAnswered => _isAnswered;
  bool get isLoading => _isLoading;
  int get unitNumber => _unitNumber;
  int get totalQuestions => _shuffledQuestions.length;

  Question get currentQuestion {
    if (_shuffledQuestions.isEmpty) {
      throw StateError('No current question available');
    }
    return _shuffledQuestions[_currentIndex];
  }

  List<String> get currentChoices =>
      _shuffledChoices.isNotEmpty ? _shuffledChoices[_currentIndex] : [];

  bool get isLastQuestion => _currentIndex >= _shuffledQuestions.length - 1;

  double get progress => _shuffledQuestions.isEmpty
      ? 0.0
      : (_currentIndex + 1) / _shuffledQuestions.length;

  Future<void> loadUnit(int unitNumber) async {
    _isLoading = true;
    _unitNumber = unitNumber;
    _currentIndex = 0;
    _score = 0;
    _answers = [];
    _selectedValues = [];
    _selectedAnswerIndex = null;
    _isAnswered = false;
    notifyListeners();

    _allQuestions = await _jsonLoader.loadUnitQuestions(unitNumber);
    _shuffleQuestions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomQuestions(int unitNumber, List<Question> questions) async {
    _isLoading = true;
    _unitNumber = unitNumber;
    _currentIndex = 0;
    _score = 0;
    _answers = [];
    _selectedValues = [];
    _selectedAnswerIndex = null;
    _isAnswered = false;
    notifyListeners();

    _allQuestions = questions;
    _shuffleQuestions();
    _isLoading = false;
    notifyListeners();
  }

  void _shuffleQuestions() {
    final random = Random();
    _shuffledQuestions = List.from(_allQuestions)..shuffle(random);
    _shuffledChoices = _shuffledQuestions.map((q) {
      final choices = List<String>.from(q.choices)..shuffle(random);
      return choices;
    }).toList();
  }

  void selectAnswer(int index) {
    if (_isAnswered) return;

    _isAnswered = true;
    _selectedAnswerIndex = index;

    final correct = currentChoices[index] == currentQuestion.answer;
    if (correct) {
      _score++;
    }
    _answers.add(correct);
    _selectedValues.add(currentChoices[index]);
    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentIndex++;
      _selectedAnswerIndex = null;
      _isAnswered = false;
      notifyListeners();
    }
  }

  QuizResult getResult() {
    return QuizResult(
      unitNumber: _unitNumber,
      score: _score,
      totalQuestions: _shuffledQuestions.length,
      answers: List.from(_answers),
    );
  }

  void reset() {
    _allQuestions = [];
    _shuffledQuestions = [];
    _shuffledChoices = [];
    _currentIndex = 0;
    _score = 0;
    _answers = [];
    _selectedValues = [];
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _isLoading = false;
    _unitNumber = 0;
    notifyListeners();
  }
}
