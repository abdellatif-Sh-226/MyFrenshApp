import '../models/course_model.dart';
import '../models/question_model.dart';

const List<Course> kCourses = [
  Course(
    title: 'Comment poser une question',
    description:
        'Apprenez les mots interrogatifs français (Qui, Quoi, Où, Quand, Comment…) pour poser des questions.',
    iconKey: 'question',
    lessons: [
      CourseLesson(
        title: 'Qui — من',
        content:
            '« Qui » تعني "من" وتُستخدم للسؤال عن شخص.\n\nمثال:\n- Qui est-ce ? = من هذا؟\n- Qui vient avec nous ? = من يأتي معنا؟',
      ),
      CourseLesson(
        title: 'Quoi — ماذا',
        content:
            '« Quoi » تعني "ماذا" وتُستخدم للسؤال عن شيء.\n\nمثال:\n- Quoi ? = ماذا؟\n- Tu fais quoi ? = ماذا تفعل؟',
      ),
      CourseLesson(
        title: 'Où — أين',
        content:
            '« Où » تعني "أين" وتُستخدم للسؤال عن المكان.\n\nمثال:\n- Où est la maison ? = أين المنزل؟\n- Où vas-tu ? = إلى أين تذهب؟',
      ),
      CourseLesson(
        title: 'Quand — متى',
        content:
            '« Quand » تعني "متى" وتُستخدم للسؤال عن الوقت.\n\nمثال:\n- Quand arrive-t-il ? = متى يصل؟\n- Quand manges-tu ? = متى تأكل؟',
      ),
      CourseLesson(
        title: 'Comment — كيف',
        content:
            '« Comment » تعني "كيف" وتُستخدم للسؤال عن الطريقة.\n\nمثال:\n- Comment vas-tu ? = كيف حالك؟\n- Comment dit-on ? = كيف نقول؟',
      ),
      CourseLesson(
        title: 'Pourquoi — لماذا',
        content:
            '« Pourquoi » تعني "لماذا" وتُستخدم للسؤال عن السبب.\n\nمثال:\n- Pourquoi ? = لماذا؟\n- Pourquoi tu pleures ? = لماذا تبكي؟',
      ),
      CourseLesson(
        title: 'Combien — كم',
        content:
            '« Combien » تعني "كم" وتُستخدم للسؤال عن العدد أو المبلغ.\n\nمثال:\n- Combien ça coûte ? = كم يكلف؟\n- Combien de livres ? = كم كتاباً؟',
      ),
      CourseLesson(
        title: 'Quel / Quelle — أي',
        content:
            '« Quel » و « Quelle » تعنيان "أي" حسب الجنس: Quel للمذكر و Quelle للمؤنث.\n\nمثال:\n- Quel livre ? = أي كتاب؟\n- Quelle est la question ? = ما هو السؤال؟',
      ),
      CourseLesson(
        title: 'Est-ce que — هل',
        content:
            '« Est-ce que » تستخدم لتحويل الجملة إلى سؤال (نعم/لا).\n\nمثال:\n- Est-ce que tu comprends ? = هل تفهم؟\n- Est-ce que le pain est bon ? = هل الخبز جيد؟',
      ),
      CourseLesson(
        title: 'Mettez tout ensemble',
        content:
            'الآن اجمع الكلمات لبناء أسئلة كاملة:\n\n- Quelle est la traduction ? = ما هي الترجمة؟\n- Comment on dit en français ? = كيف نقول بالفرنسية؟\n- Où est la salle de bain ? = أين الحمام؟\n- Pourquoi est-ce difficile ? = لماذا هذا صعب؟',
      ),
    ],
    questions: [
      Question(
        word: 'Qui',
        choices: ['من', 'أين', 'متى', 'كيف'],
        answer: 'من',
        meaning: 'Le mot « Qui » sert à demander une personne.',
        example: 'Qui est-ce ?',
        arabicTranslation: 'من',
      ),
      Question(
        word: 'Quoi',
        choices: ['أين', 'ماذا', 'كم', 'لماذا'],
        answer: 'ماذا',
        meaning: 'Le mot « Quoi » sert à demander une chose.',
        example: 'Tu fais quoi ?',
        arabicTranslation: 'ماذا',
      ),
      Question(
        word: 'Où',
        choices: ['متى', 'من', 'أين', 'كيف'],
        answer: 'أين',
        meaning: 'Le mot « Où » sert à demander un lieu.',
        example: 'Où est la maison ?',
        arabicTranslation: 'أين',
      ),
      Question(
        word: 'Quand',
        choices: ['كيف', 'متى', 'ماذا', 'كم'],
        answer: 'متى',
        meaning: 'Le mot « Quand » sert à demander un moment.',
        example: 'Quand arrives-tu ?',
        arabicTranslation: 'متى',
      ),
      Question(
        word: 'Comment',
        choices: ['لماذا', 'كم', 'متى', 'كيف'],
        answer: 'كيف',
        meaning: 'Le mot « Comment » sert à demander une manière.',
        example: 'Comment vas-tu ?',
        arabicTranslation: 'كيف',
      ),
      Question(
        word: 'Pourquoi',
        choices: ['ماذا', 'لماذا', 'أين', 'من'],
        answer: 'لماذا',
        meaning: 'Le mot « Pourquoi » sert à demander une raison.',
        example: 'Pourquoi ?',
        arabicTranslation: 'لماذا',
      ),
      Question(
        word: 'Combien',
        choices: ['كم', 'كيف', 'متى', 'ماذا'],
        answer: 'كم',
        meaning: 'Le mot « Combien » sert à demander une quantité.',
        example: 'Combien ça coûte ?',
        arabicTranslation: 'كم',
      ),
      Question(
        word: 'Quel',
        choices: ['أي (مذكر)', 'كم', 'أين', 'كيف'],
        answer: 'أي (مذكر)',
        meaning: 'Le mot « Quel » sert à choisir (masculin).',
        example: 'Quel livre ?',
        arabicTranslation: 'أي',
      ),
      Question(
        word: 'Quelle',
        choices: ['لماذا', 'أي (مؤنث)', 'متى', 'من'],
        answer: 'أي (مؤنث)',
        meaning: 'Le mot « Quelle » sert à choisir (féminin).',
        example: 'Quelle est la question ?',
        arabicTranslation: 'أي',
      ),
      Question(
        word: 'Est-ce que',
        choices: ['هل', 'كم', 'متى', 'لماذا'],
        answer: 'هل',
        meaning: '« Est-ce que » transforme une phrase en question.',
        example: 'Est-ce que tu comprends ?',
        arabicTranslation: 'هل',
      ),
    ],
  ),
];
