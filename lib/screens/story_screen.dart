import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/answer_button.dart';

class Story {
  final String title;
  final String content;
  final List<StoryQuestion> questions;

  const Story({
    required this.title,
    required this.content,
    required this.questions,
  });
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
}

const List<Story> kStories = [
  Story(
    title: 'Story 1: Le Marché du Matin',
    content:
        'Le matin, le soleil brille. Nadia ouvre la porte de sa maison et regarde son jardin. Elle dit bonjour à son chien et à son chat. Elle prend un panier et elle va au marché avec son ami Karim.\n\n'
        'Au marché, il y a beaucoup de magasins. Nadia achète du pain et de la viande. Karim achète de l\'eau et du lait. Le vendeur dit : « Ça coûte vingt euros. » Nadia paie et Karim donne un livre au vendeur. Le vendeur dit : « Merci ! »\n\n'
        'Après le marché, ils rentrent à la maison. La mère de Nadia cuisine dans la cuisine. Nadia lave la table et Karim range les chaises. Le soir, ils dînent ensemble. La lune brille et tout le monde est content.',
    questions: [
      StoryQuestion(
        question: 'Que dit Nadia à ses animaux ?',
        options: ['Au revoir', 'Bonjour', 'Merci', 'S\'il vous plaît'],
        correctAnswer: 'Bonjour',
      ),
      StoryQuestion(
        question: 'Où va Nadia avec Karim ?',
        options: ['À l\'école', 'Au marché', 'À la montagne', 'À la bibliothèque'],
        correctAnswer: 'Au marché',
      ),
      StoryQuestion(
        question: 'Qu\'achète Nadia ?',
        options: ['De l\'eau et du lait', 'Des fleurs et un livre', 'Du pain et de la viande', 'Une voiture et un chien'],
        correctAnswer: 'Du pain et de la viande',
      ),
      StoryQuestion(
        question: 'Qu\'achète Karim ?',
        options: ['Du pain et de la viande', 'De l\'eau et du lait', 'Un chat et une chaise', 'Un journal et des chaussures'],
        correctAnswer: 'De l\'eau et du lait',
      ),
      StoryQuestion(
        question: 'Combien coûte le panier ?',
        options: ['Dix euros', 'Cinq euros', 'Vingt euros', 'Trente euros'],
        correctAnswer: 'Vingt euros',
      ),
      StoryQuestion(
        question: 'Que donne Karim au vendeur ?',
        options: ['Un livre', 'Une fleur', 'De l\'eau', 'Du pain'],
        correctAnswer: 'Un livre',
      ),
      StoryQuestion(
        question: 'Qui cuisine le soir ?',
        options: ['Karim', 'Le vendeur', 'Nadia', 'La mère de Nadia'],
        correctAnswer: 'La mère de Nadia',
      ),
      StoryQuestion(
        question: 'Que lave Nadia ?',
        options: ['La table', 'La fenêtre', 'La voiture', 'Le lit'],
        correctAnswer: 'La table',
      ),
      StoryQuestion(
        question: 'Que range Karim ?',
        options: ['Les chaises', 'Les livres', 'Les fleurs', 'Les portes'],
        correctAnswer: 'Les chaises',
      ),
      StoryQuestion(
        question: 'Quand est-ce qu\'ils dînent ?',
        options: ['Le matin', 'Le soir', 'À midi', 'La nuit'],
        correctAnswer: 'Le soir',
      ),
    ],
  ),
  Story(
    title: 'Story 2: Le Voyage de Karim',
    content:
        'Karim veut voyager. Il décide de visiter un nouveau pays avec sa voiture. Le matin, il ferme la porte de sa maison, il monte dans la voiture et il commence à conduire. Le chemin passe par les montagnes et près d\'une rivière.\n\n'
        'Dans la ville, Karim rencontre une femme. Elle s\'appelle Marie. Karim demande : « Où est le magasin ? » Marie explique : « Tournez à droite et continuez tout droit. » Karim comprend et il dit : « Merci ! »\n\n'
        'Karim visite le marché et il essaie de parler français. Il réussit ! Il regarde la ville, il marche près de la rivière et il nage un peu. Le soir, il pense à son voyage et il est très content.',
    questions: [
      StoryQuestion(
        question: 'Qu\'est-ce que Karim veut faire ?',
        options: ['Travailler', 'Voyager', 'Étudier', 'Dormir'],
        correctAnswer: 'Voyager',
      ),
      StoryQuestion(
        question: 'Comment voyage Karim ?',
        options: ['En voiture', 'En train', 'À pied', 'En avion'],
        correctAnswer: 'En voiture',
      ),
      StoryQuestion(
        question: 'Où passe le chemin ?',
        options: ['Par la ville et l\'école', 'Par les montagnes et près d\'une rivière', 'Par le marché et le magasin', 'Par le jardin et la maison'],
        correctAnswer: 'Par les montagnes et près d\'une rivière',
      ),
      StoryQuestion(
        question: 'Qui rencontre Karim dans la ville ?',
        options: ['Un professeur', 'Son père', 'Une femme qui s\'appelle Marie', 'Un vendeur de pain'],
        correctAnswer: 'Une femme qui s\'appelle Marie',
      ),
      StoryQuestion(
        question: 'Que demande Karim ?',
        options: ['Comment vas-tu ?', 'Où est le magasin ?', 'Quelle heure est-il ?', 'Combien ça coûte ?'],
        correctAnswer: 'Où est le magasin ?',
      ),
      StoryQuestion(
        question: 'Que dit Marie à Karim ?',
        options: ['Fermez la porte', 'Tournez à droite et continuez tout droit', 'Buvez de l\'eau', 'Jetez le livre'],
        correctAnswer: 'Tournez à droite et continuez tout droit',
      ),
      StoryQuestion(
        question: 'Est-ce que Karim comprend ?',
        options: ['Non, il échoue', 'Oui, il comprend', 'Il ne parle pas', 'Il dort'],
        correctAnswer: 'Oui, il comprend',
      ),
      StoryQuestion(
        question: 'Qu\'est-ce que Karim essaie de faire ?',
        options: ['De parler français', 'De conduire', 'D\'acheter une maison', 'De courir'],
        correctAnswer: 'De parler français',
      ),
      StoryQuestion(
        question: 'Est-ce que Karim réussit ?',
        options: ['Non', 'Oui, il réussit', 'Il essaie encore', 'Il refuse'],
        correctAnswer: 'Oui, il réussit',
      ),
      StoryQuestion(
        question: 'Où Karim nage-t-il un peu ?',
        options: ['Dans la rivière', 'Dans la cuisine', 'Au marché', 'Dans le magasin'],
        correctAnswer: 'Dans la rivière',
      ),
    ],
  ),
  Story(
    title: 'Story 3: La Fête de Claire',
    content:
        'Claire organise une fête dans sa maison. Elle invite ses amis et ils acceptent. Le matin, Claire lave la cuisine, nettoie la salle de bain et range les chambres. Elle ouvre la fenêtre pour que le soleil entre.\n\n'
        'Au marché, elle achète du pain, de la viande et des fleurs. Elle choisit de belles fleurs rouges. Son ami Sami ne peut pas venir, il refuse l\'invitation, mais il donne un cadeau à Claire.\n\n'
        'Le soir, les amis arrivent. Ils jouent de la musique et ils chantent. Sami vient aussi et il danse. La mère de Claire cuisine un bon dîner et tout le monde mange. Après le dîner, Claire apprend à ses amis une nouvelle danse. Ils s\'amusent jusqu\'à la nuit.',
    questions: [
      StoryQuestion(
        question: 'Qu\'est-ce que Claire organise ?',
        options: ['Une fête', 'Un voyage', 'Un cours', 'Une école'],
        correctAnswer: 'Une fête',
      ),
      StoryQuestion(
        question: 'Que font les amis de Claire ?',
        options: ['Ils refusent', 'Ils acceptent l\'invitation', 'Ils dorment', 'Ils partent'],
        correctAnswer: 'Ils acceptent l\'invitation',
      ),
      StoryQuestion(
        question: 'Que nettoie Claire le matin ?',
        options: ['La salle de bain', 'Le jardin', 'La voiture', 'Le marché'],
        correctAnswer: 'La salle de bain',
      ),
      StoryQuestion(
        question: 'Que fait Claire avec la fenêtre ?',
        options: ['Elle la ferme', 'Elle la lave', 'Elle l\'ouvre', 'Elle la pousse'],
        correctAnswer: 'Elle l\'ouvre',
      ),
      StoryQuestion(
        question: 'Qu\'est-ce que Claire achète au marché ?',
        options: ['De l\'eau et du lait', 'Du pain, de la viande et des fleurs', 'Un livre et un lit', 'Une chaise et une table'],
        correctAnswer: 'Du pain, de la viande et des fleurs',
      ),
      StoryQuestion(
        question: 'Pourquoi Sami refuse l\'invitation ?',
        options: ['Il est malade', 'Il ne peut pas venir', 'Il déteste Claire', 'Il travaille trop'],
        correctAnswer: 'Il ne peut pas venir',
      ),
      StoryQuestion(
        question: 'Que fait Sami pour Claire ?',
        options: ['Il lui donne un cadeau', 'Il lui jette une pierre', 'Il ferme sa porte', 'Il achète sa maison'],
        correctAnswer: 'Il lui donne un cadeau',
      ),
      StoryQuestion(
        question: 'Que font les amis avec la musique ?',
        options: ['Ils écoutent et ils chantent', 'Ils l\'achètent', 'Ils la jettent', 'Ils la portent'],
        correctAnswer: 'Ils écoutent et ils chantent',
      ),
      StoryQuestion(
        question: 'Qui cuisine le dîner ?',
        options: ['Claire', 'Sami', 'La mère de Claire', 'Le vendeur'],
        correctAnswer: 'La mère de Claire',
      ),
      StoryQuestion(
        question: 'Qu\'est-ce que Claire apprend à ses amis ?',
        options: ['Une nouvelle danse', 'Une chanson', 'Un livre', 'Une recette'],
        correctAnswer: 'Une nouvelle danse',
      ),
    ],
  ),
];

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

class StoryListView extends StatelessWidget {
  const StoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kStories.length,
      itemBuilder: (context, index) {
        final story = kStories[index];
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
