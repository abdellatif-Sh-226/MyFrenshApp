import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/question_model.dart';

/// Dialog to create or edit a multiple-choice Question.
/// Returns the resulting [Question] via Navigator.pop.
class QuestionEditDialog extends StatefulWidget {
  final Question? initial;

  const QuestionEditDialog({super.key, this.initial});

  @override
  State<QuestionEditDialog> createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<QuestionEditDialog> {
  late final TextEditingController _word;
  late final List<TextEditingController> _choices;
  late final TextEditingController _meaning;
  late final TextEditingController _example;
  late final TextEditingController _arabic;
  int _answerIndex = 0;

  @override
  void initState() {
    super.initState();
    final q = widget.initial;
    _word = TextEditingController(text: q?.word ?? '');
    final choices = q?.choices ?? const ['', '', '', ''];
    _choices = List.generate(4, (i) => TextEditingController(text: i < choices.length ? choices[i] : ''));
    _meaning = TextEditingController(text: q?.meaning ?? '');
    _example = TextEditingController(text: q?.example ?? '');
    _arabic = TextEditingController(text: q?.arabicTranslation ?? '');
    _answerIndex = choices.indexOf(q?.answer ?? '');
    if (_answerIndex < 0) _answerIndex = 0;
  }

  @override
  void dispose() {
    _word.dispose();
    for (final c in _choices) {
      c.dispose();
    }
    _meaning.dispose();
    _example.dispose();
    _arabic.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_word.text.trim().isEmpty) return 'Word is required';
    for (int i = 0; i < _choices.length; i++) {
      if (_choices[i].text.trim().isEmpty) {
        return 'Choice ${i + 1} is required';
      }
    }
    return null;
  }

  void _save() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Navigator.pop(
      context,
      Question(
        word: _word.text.trim(),
        choices: _choices.map((c) => c.text.trim()).toList(),
        answer: _choices[_answerIndex].text.trim(),
        meaning: _meaning.text.trim(),
        example: _example.text.trim(),
        arabicTranslation: _arabic.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.initial == null ? 'Add Question' : 'Edit Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _word,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'French word'),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _choices.length; i++) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _choices[i],
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      decoration: InputDecoration(labelText: 'Choice ${i + 1} (Arabic)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Answer'),
                    selected: _answerIndex == i,
                    selectedColor: AppTheme.correctGreen,
                    onSelected: (_) => setState(() => _answerIndex = i),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            TextField(
              controller: _meaning,
              decoration: const InputDecoration(labelText: 'Meaning / usage (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _example,
              decoration: const InputDecoration(labelText: 'Example (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _arabic,
              decoration: const InputDecoration(labelText: 'Arabic translation (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
