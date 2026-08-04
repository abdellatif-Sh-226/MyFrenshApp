// Mirror of the app's kStories / kCourses so the backend is the source of truth.

export const seedStories = [
  {
    title: 'Story 1: Le Marché du Matin',
    content:
      'Le matin, le soleil brille. Nadia ouvre la porte de sa maison et regarde son jardin. Elle dit bonjour à son chien et à son chat. Elle prend un panier et elle va au marché avec son ami Karim.\n\n' +
      'Au marché, il y a beaucoup de magasins. Nadia achète du pain et de la viande. Karim achète de l\'eau et du lait. Le vendeur dit : « Ça coûte vingt euros. » Nadia paie et Karim donne un livre au vendeur. Le vendeur dit : « Merci ! »\n\n' +
      'Après le marché, ils rentrent à la maison. La mère de Nadia cuisine dans la cuisine. Nadia lave la table et Karim range les chaises. Le soir, ils dînent ensemble. La lune brille et tout le monde est content.',
    questions: [
      { question: 'Que dit Nadia à ses animaux ?', options: ['Au revoir', 'Bonjour', 'Merci', 'S\'il vous plaît'], correctAnswer: 'Bonjour' },
      { question: 'Où va Nadia avec Karim ?', options: ['À l\'école', 'Au marché', 'À la montagne', 'À la bibliothèque'], correctAnswer: 'Au marché' },
      { question: 'Qu\'achète Nadia ?', options: ['De l\'eau et du lait', 'Des fleurs et un livre', 'Du pain et de la viande', 'Une voiture et un chien'], correctAnswer: 'Du pain et de la viande' },
      { question: 'Qu\'achète Karim ?', options: ['Du pain et de la viande', 'De l\'eau et du lait', 'Un chat et une chaise', 'Un journal et des chaussures'], correctAnswer: 'De l\'eau et du lait' },
      { question: 'Combien coûte le panier ?', options: ['Dix euros', 'Cinq euros', 'Vingt euros', 'Trente euros'], correctAnswer: 'Vingt euros' },
      { question: 'Que donne Karim au vendeur ?', options: ['Un livre', 'Une fleur', 'De l\'eau', 'Du pain'], correctAnswer: 'Un livre' },
      { question: 'Qui cuisine le soir ?', options: ['Karim', 'Le vendeur', 'Nadia', 'La mère de Nadia'], correctAnswer: 'La mère de Nadia' },
      { question: 'Que lave Nadia ?', options: ['La table', 'La fenêtre', 'La voiture', 'Le lit'], correctAnswer: 'La table' },
      { question: 'Que range Karim ?', options: ['Les chaises', 'Les livres', 'Les fleurs', 'Les portes'], correctAnswer: 'Les chaises' },
      { question: 'Quand est-ce qu\'ils dînent ?', options: ['Le matin', 'Le soir', 'À midi', 'La nuit'], correctAnswer: 'Le soir' },
    ],
  },
  {
    title: 'Story 2: Le Voyage de Karim',
    content:
      'Karim veut voyager. Il décide de visiter un nouveau pays avec sa voiture. Le matin, il ferme la porte de sa maison, il monte dans la voiture et il commence à conduire. Le chemin passe par les montagnes et près d\'une rivière.\n\n' +
      'Dans la ville, Karim rencontre une femme. Elle s\'appelle Marie. Karim demande : « Où est le magasin ? » Marie explique : « Tournez à droite et continuez tout droit. » Karim comprend et il dit : « Merci ! »\n\n' +
      'Karim visite le marché et il essaie de parler français. Il réussit ! Il regarde la ville, il marche près de la rivière et il nage un peu. Le soir, il pense à son voyage et il est très content.',
    questions: [
      { question: 'Qu\'est-ce que Karim veut faire ?', options: ['Travailler', 'Voyager', 'Étudier', 'Dormir'], correctAnswer: 'Voyager' },
      { question: 'Comment voyage Karim ?', options: ['En voiture', 'En train', 'À pied', 'En avion'], correctAnswer: 'En voiture' },
      { question: 'Où passe le chemin ?', options: ['Par la ville et l\'école', 'Par les montagnes et près d\'une rivière', 'Par le marché et le magasin', 'Par le jardin et la maison'], correctAnswer: 'Par les montagnes et près d\'une rivière' },
      { question: 'Qui rencontre Karim dans la ville ?', options: ['Un professeur', 'Son père', 'Une femme qui s\'appelle Marie', 'Un vendeur de pain'], correctAnswer: 'Une femme qui s\'appelle Marie' },
      { question: 'Que demande Karim ?', options: ['Comment vas-tu ?', 'Où est le magasin ?', 'Quelle heure est-il ?', 'Combien ça coûte ?'], correctAnswer: 'Où est le magasin ?' },
      { question: 'Que dit Marie à Karim ?', options: ['Fermez la porte', 'Tournez à droite et continuez tout droit', 'Buvez de l\'eau', 'Jetez le livre'], correctAnswer: 'Tournez à droite et continuez tout droit' },
      { question: 'Est-ce que Karim comprend ?', options: ['Non, il échoue', 'Oui, il comprend', 'Il ne parle pas', 'Il dort'], correctAnswer: 'Oui, il comprend' },
      { question: 'Qu\'est-ce que Karim essaie de faire ?', options: ['De parler français', 'De conduire', 'D\'acheter une maison', 'De courir'], correctAnswer: 'De parler français' },
      { question: 'Est-ce que Karim réussit ?', options: ['Non', 'Oui, il réussit', 'Il essaie encore', 'Il refuse'], correctAnswer: 'Oui, il réussit' },
      { question: 'Où Karim nage-t-il un peu ?', options: ['Dans la rivière', 'Dans la cuisine', 'Au marché', 'Dans le magasin'], correctAnswer: 'Dans la rivière' },
    ],
  },
  {
    title: 'Story 3: La Fête de Claire',
    content:
      'Claire organise une fête dans sa maison. Elle invite ses amis et ils acceptent. Le matin, Claire lave la cuisine, nettoie la salle de bain et range les chambres. Elle ouvre la fenêtre pour que le soleil entre.\n\n' +
      'Au marché, elle achète du pain, de la viande et des fleurs. Elle choisit de belles fleurs rouges. Son ami Sami ne peut pas venir, il refuse l\'invitation, mais il donne un cadeau à Claire.\n\n' +
      'Le soir, les amis arrivent. Ils jouent de la musique et ils chantent. Sami vient aussi et il danse. La mère de Claire cuisine un bon dîner et tout le monde mange. Après le dîner, Claire apprend à ses amis une nouvelle danse. Ils s\'amusent jusqu\'à la nuit.',
    questions: [
      { question: 'Qu\'est-ce que Claire organise ?', options: ['Une fête', 'Un voyage', 'Un cours', 'Une école'], correctAnswer: 'Une fête' },
      { question: 'Que font les amis de Claire ?', options: ['Ils refusent', 'Ils acceptent l\'invitation', 'Ils dorment', 'Ils partent'], correctAnswer: 'Ils acceptent l\'invitation' },
      { question: 'Que nettoie Claire le matin ?', options: ['La salle de bain', 'Le jardin', 'La voiture', 'Le marché'], correctAnswer: 'La salle de bain' },
      { question: 'Que fait Claire avec la fenêtre ?', options: ['Elle la ferme', 'Elle la lave', 'Elle l\'ouvre', 'Elle la pousse'], correctAnswer: 'Elle l\'ouvre' },
      { question: 'Qu\'est-ce que Claire achète au marché ?', options: ['De l\'eau et du lait', 'Du pain, de la viande et des fleurs', 'Un livre et un lit', 'Une chaise et une table'], correctAnswer: 'Du pain, de la viande et des fleurs' },
      { question: 'Pourquoi Sami refuse l\'invitation ?', options: ['Il est malade', 'Il ne peut pas venir', 'Il déteste Claire', 'Il travaille trop'], correctAnswer: 'Il ne peut pas venir' },
      { question: 'Que fait Sami pour Claire ?', options: ['Il lui donne un cadeau', 'Il lui jette une pierre', 'Il ferme sa porte', 'Il achète sa maison'], correctAnswer: 'Il lui donne un cadeau' },
      { question: 'Que font les amis avec la musique ?', options: ['Ils écoutent et ils chantent', 'Ils l\'achètent', 'Ils la jettent', 'Ils la portent'], correctAnswer: 'Ils écoutent et ils chantent' },
      { question: 'Qui cuisine le dîner ?', options: ['Claire', 'Sami', 'La mère de Claire', 'Le vendeur'], correctAnswer: 'La mère de Claire' },
      { question: 'Qu\'est-ce que Claire apprend à ses amis ?', options: ['Une nouvelle danse', 'Une chanson', 'Un livre', 'Une recette'], correctAnswer: 'Une nouvelle danse' },
    ],
  },
];

export const seedCourses = [
  {
    title: 'Comment poser une question',
    description:
      'Apprenez les mots interrogatifs français (Qui, Quoi, Où, Quand, Comment…) pour poser des questions.',
    iconKey: 'question',
    lessons: [
      { title: 'Qui — من', content: '« Qui » تعني "من" وتُستخدم للسؤال عن شخص.\n\nمثال:\n- Qui est-ce ? = من هذا؟\n- Qui vient avec nous ? = من يأتي معنا؟' },
      { title: 'Quoi — ماذا', content: '« Quoi » تعني "ماذا" وتُستخدم للسؤال عن شيء.\n\nمثال:\n- Quoi ? = ماذا؟\n- Tu fais quoi ? = ماذا تفعل؟' },
      { title: 'Où — أين', content: '« Où » تعني "أين" وتُستخدم للسؤال عن المكان.\n\nمثال:\n- Où est la maison ? = أين المنزل؟\n- Où vas-tu ? = إلى أين تذهب؟' },
      { title: 'Quand — متى', content: '« Quand » تعني "متى" وتُستخدم للسؤال عن الوقت.\n\nمثال:\n- Quand arrive-t-il ? = متى يصل؟\n- Quand manges-tu ? = متى تأكل؟' },
      { title: 'Comment — كيف', content: '« Comment » تعني "كيف" وتُستخدم للسؤال عن الطريقة.\n\nمثال:\n- Comment vas-tu ? = كيف حالك؟\n- Comment dit-on ? = كيف نقول؟' },
      { title: 'Pourquoi — لماذا', content: '« Pourquoi » تعني "لماذا" وتُستخدم للسؤال عن السبب.\n\nمثال:\n- Pourquoi ? = لماذا؟\n- Pourquoi tu pleures ? = لماذا تبكي؟' },
      { title: 'Combien — كم', content: '« Combien » تعني "كم" وتُستخدم للسؤال عن العدد أو المبلغ.\n\nمثال:\n- Combien ça coûte ? = كم يكلف؟\n- Combien de livres ? = كم كتاباً؟' },
      { title: 'Quel / Quelle — أي', content: '« Quel » و « Quelle » تعنيان "أي" حسب الجنس: Quel للمذكر و Quelle للمؤنث.\n\nمثال:\n- Quel livre ? = أي كتاب؟\n- Quelle est la question ? = ما هو السؤال؟' },
      { title: 'Est-ce que — هل', content: '« Est-ce que » تستخدم لتحويل الجملة إلى سؤال (نعم/لا).\n\nمثال:\n- Est-ce que tu comprends ? = هل تفهم؟\n- Est-ce que le pain est bon ? = هل الخبز جيد؟' },
      { title: 'Mettez tout ensemble', content: 'الآن اجمع الكلمات لبناء أسئلة كاملة:\n\n- Quelle est la traduction ? = ما هي الترجمة؟\n- Comment on dit en français ? = كيف نقول بالفرنسية؟\n- Où est la salle de bain ? = أين الحمام؟\n- Pourquoi est-ce difficile ? = لماذا هذا صعب؟' },
    ],
    questions: [
      { word: 'Qui', choices: ['من', 'أين', 'متى', 'كيف'], answer: 'من', meaning: 'Le mot « Qui » sert à demander une personne.', example: 'Qui est-ce ?', arabicTranslation: 'من' },
      { word: 'Quoi', choices: ['أين', 'ماذا', 'كم', 'لماذا'], answer: 'ماذا', meaning: 'Le mot « Quoi » sert à demander une chose.', example: 'Tu fais quoi ?', arabicTranslation: 'ماذا' },
      { word: 'Où', choices: ['متى', 'من', 'أين', 'كيف'], answer: 'أين', meaning: 'Le mot « Où » sert à demander un lieu.', example: 'Où est la maison ?', arabicTranslation: 'أين' },
      { word: 'Quand', choices: ['كيف', 'متى', 'ماذا', 'كم'], answer: 'متى', meaning: 'Le mot « Quand » sert à demander un moment.', example: 'Quand arrives-tu ?', arabicTranslation: 'متى' },
      { word: 'Comment', choices: ['لماذا', 'كم', 'متى', 'كيف'], answer: 'كيف', meaning: 'Le mot « Comment » sert à demander une manière.', example: 'Comment vas-tu ?', arabicTranslation: 'كيف' },
      { word: 'Pourquoi', choices: ['ماذا', 'لماذا', 'أين', 'من'], answer: 'لماذا', meaning: 'Le mot « Pourquoi » sert à demander une raison.', example: 'Pourquoi ?', arabicTranslation: 'لماذا' },
      { word: 'Combien', choices: ['كم', 'كيف', 'متى', 'ماذا'], answer: 'كم', meaning: 'Le mot « Combien » sert à demander une quantité.', example: 'Combien ça coûte ?', arabicTranslation: 'كم' },
      { word: 'Quel', choices: ['أي (مذكر)', 'كم', 'أين', 'كيف'], answer: 'أي (مذكر)', meaning: 'Le mot « Quel » sert à choisir (masculin).', example: 'Quel livre ?', arabicTranslation: 'أي' },
      { word: 'Quelle', choices: ['لماذا', 'أي (مؤنث)', 'متى', 'من'], answer: 'أي (مؤنث)', meaning: 'Le mot « Quelle » sert à choisir (féminin).', example: 'Quelle est la question ?', arabicTranslation: 'أي' },
      { word: 'Est-ce que', choices: ['هل', 'كم', 'متى', 'لماذا'], answer: 'هل', meaning: '« Est-ce que » transforme une phrase en question.', example: 'Est-ce que tu comprends ?', arabicTranslation: 'هل' },
    ],
  },
];
