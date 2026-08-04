import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/story_model.dart';
import '../providers/content_provider.dart';
import '../widgets/answer_button.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: const StoryListView(),
    );
  }
}

class StoryListView extends StatefulWidget {
  const StoryListView({super.key});

  @override
  State<StoryListView> createState() => _StoryListViewState();
}

class _StoryListViewState extends State<StoryListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final content = context.read<ContentProvider>();
      if (content.stories.isEmpty) content.loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final stories = content.stories;

    if (content.loading && stories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openStory(context, story),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    story.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.quiz_outlined, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Comprehension quiz',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openStory(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryDetailScreen(story: story),
      ),
    );
  }
}

enum _StoryPhase { read, quiz, result }

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  _StoryPhase _phase = _StoryPhase.read;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  StoryQuestion get currentQuestion =>
      widget.story.questions[_currentQuestionIndex];

  bool get isLastQuestion =>
      _currentQuestionIndex >= widget.story.questions.length - 1;

  double get _percentage =>
      widget.story.questions.isEmpty ? 0 : _score / widget.story.questions.length;

  void _startQuiz() {
    setState(() {
      _phase = _StoryPhase.quiz;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  void _submitAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = index;
      if (currentQuestion.options[index] == currentQuestion.correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (isLastQuestion) {
      setState(() {
        _phase = _StoryPhase.result;
      });
      return;
    }
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  void _restart() {
    setState(() {
      _phase = _StoryPhase.read;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.story.title)),
      body: switch (_phase) {
        _StoryPhase.read => _buildReadPhase(context),
        _StoryPhase.quiz => _buildQuizPhase(context),
        _StoryPhase.result => _buildResultPhase(context),
      },
    );
  }

  Widget _buildReadPhase(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Read the story',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.story.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.quiz_outlined),
              label: Text(
                'Start Comprehension Quiz (${widget.story.questions.length})',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizPhase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.story.questions.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.story.questions.length,
              minHeight: 8,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            currentQuestion.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: currentQuestion.options.length,
            itemBuilder: (context, index) {
              final correct =
                  currentQuestion.options[index] == currentQuestion.correctAnswer;
              return AnswerButton(
                text: currentQuestion.options[index],
                index: index,
                isCorrect: correct,
                isSelected: _selectedAnswerIndex == index,
                isAnswered: _isAnswered,
                onTap: () => _submitAnswer(index),
              );
            },
          ),
        ),
        if (_isAnswered)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(isLastQuestion ? 'See Result' : 'Next'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultPhase(BuildContext context) {
    final passed = _percentage >= 0.5;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.replay_circle_filled_outlined,
              size: 72,
              color: passed ? AppTheme.accentColor : AppTheme.wrongRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Story Result',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '$_score / ${widget.story.questions.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_percentage * 100).round()}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              passed
                  ? 'Great job! You understood the story well.'
                  : 'Review the story and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay),
                label: const Text('Retake Story'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Stories'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
