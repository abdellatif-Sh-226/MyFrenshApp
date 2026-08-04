import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/story_model.dart';

/// Dialog to create or edit a comprehension question for a story.
/// Returns the resulting [StoryQuestion] via Navigator.pop.
class StoryQuestionEditDialog extends StatefulWidget {
  final StoryQuestion? initial;

  const StoryQuestionEditDialog({super.key, this.initial});

  @override
  State<StoryQuestionEditDialog> createState() => _StoryQuestionEditDialogState();
}

class _StoryQuestionEditDialogState extends State<StoryQuestionEditDialog> {
  late final TextEditingController _question;
  late final List<TextEditingController> _options;
  int _answerIndex = 0;

  @override
  void initState() {
    super.initState();
    final q = widget.initial;
    _question = TextEditingController(text: q?.question ?? '');
    final options = q?.options ?? const ['', '', '', ''];
    _options = List.generate(
      4,
      (i) => TextEditingController(text: i < options.length ? options[i] : ''),
    );
    _answerIndex = options.indexOf(q?.correctAnswer ?? '');
    if (_answerIndex < 0) _answerIndex = 0;
  }

  @override
  void dispose() {
    _question.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_question.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question text is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    for (int i = 0; i < _options.length; i++) {
      if (_options[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Option ${i + 1} is required'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    Navigator.pop(
      context,
      StoryQuestion(
        question: _question.text.trim(),
        options: _options.map((o) => o.text.trim()).toList(),
        correctAnswer: _options[_answerIndex].text.trim(),
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
              controller: _question,
              decoration: const InputDecoration(labelText: 'Question (French)'),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _options.length; i++) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _options[i],
                      decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Correct'),
                    selected: _answerIndex == i,
                    selectedColor: AppTheme.correctGreen,
                    onSelected: (_) => setState(() => _answerIndex = i),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
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
