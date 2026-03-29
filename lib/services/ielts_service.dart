import 'package:ez_trainz/models/ielts.dart';

/// IELTS content service providing research-based practice materials.
///
/// Content is structured around the 4 IELTS sections with strategies
/// derived from top-scoring research:
/// - Cambridge IELTS official materials structure
/// - Band descriptor-aligned difficulty progression
/// - High-frequency academic vocabulary (AWL)
/// - Common IELTS topic themes and question patterns
class IeltsService {
  // ── Band Descriptors (Official IELTS Scale) ───────────────────────
  static const List<IeltsBandDescriptor> bandDescriptors = [
    IeltsBandDescriptor(
      band: 9.0,
      level: 'Expert',
      description: 'Full command of the language. Appropriate, accurate and fluent with complete understanding.',
      sectionDescriptors: {
        IeltsSection.reading: 'Reads effortlessly with full comprehension of implicit meaning.',
        IeltsSection.listening: 'Understands everything with no difficulty; follows complex arguments.',
        IeltsSection.writing: 'Uses language with full flexibility and precision in all contexts.',
        IeltsSection.speaking: 'Speaks with full fluency, precision and natural usage throughout.',
      },
    ),
    IeltsBandDescriptor(
      band: 8.0,
      level: 'Very Good',
      description: 'Fully operational command with occasional inaccuracies. Handles complex arguments well.',
      sectionDescriptors: {
        IeltsSection.reading: 'Reads with ease. Rare difficulty with unusual or idiomatic language.',
        IeltsSection.listening: 'Follows extended speech well. Rare misunderstandings.',
        IeltsSection.writing: 'Wide range of structures used flexibly. Rare errors.',
        IeltsSection.speaking: 'Fluent with only very occasional repetition. Wide vocabulary range.',
      },
    ),
    IeltsBandDescriptor(
      band: 7.0,
      level: 'Good',
      description: 'Operational command with occasional inaccuracies. Generally handles complex language well.',
      sectionDescriptors: {
        IeltsSection.reading: 'Can read most texts well. Occasional difficulty with low-frequency vocabulary.',
        IeltsSection.listening: 'Generally understands detailed argument. Some difficulty with unfamiliar topics.',
        IeltsSection.writing: 'Good range of vocabulary and structures. Some errors but meaning is clear.',
        IeltsSection.speaking: 'Speaks at length without noticeable effort. Some hesitation when searching for language.',
      },
    ),
    IeltsBandDescriptor(
      band: 6.0,
      level: 'Competent',
      description: 'Generally effective command despite inaccuracies. Can use and understand fairly complex language.',
      sectionDescriptors: {
        IeltsSection.reading: 'Can understand main ideas. May have difficulty with detail and inference.',
        IeltsSection.listening: 'Generally understands straightforward factual information.',
        IeltsSection.writing: 'Adequate range of vocabulary. Some errors in grammar and spelling.',
        IeltsSection.speaking: 'Willing to speak at length but coherence may be lost. Some self-correction.',
      },
    ),
    IeltsBandDescriptor(
      band: 5.0,
      level: 'Modest',
      description: 'Partial command. Likely to make many mistakes. Should be able to handle basic communication.',
      sectionDescriptors: {
        IeltsSection.reading: 'Partial understanding. Frequent problems with meaning and vocabulary.',
        IeltsSection.listening: 'Generally understands simple, direct speech on familiar topics.',
        IeltsSection.writing: 'Limited range of vocabulary. Noticeable errors in grammar.',
        IeltsSection.speaking: 'Can maintain flow but uses simple structures. Frequent pauses.',
      },
    ),
  ];

  // ── Reading Passages ──────────────────────────────────────────────
  static const List<IeltsReadingPassage> readingPassages = [
    IeltsReadingPassage(
      id: 'r001',
      title: 'The Impact of Artificial Intelligence on Education',
      source: 'Academic Journal Adaptation',
      difficulty: IeltsDifficulty.band7,
      timeLimitMinutes: 20,
      passage: '''Artificial Intelligence (AI) is rapidly transforming the landscape of education across the globe. From personalized learning algorithms that adapt to individual student needs to automated grading systems that provide instant feedback, AI technologies are reshaping how knowledge is delivered and assessed.

One of the most significant applications of AI in education is adaptive learning platforms. These systems analyze student performance data in real-time, identifying knowledge gaps and adjusting the difficulty and content of materials accordingly. Research conducted at Stanford University demonstrated that students using AI-powered adaptive learning tools showed a 30% improvement in test scores compared to those following traditional curricula.

However, the integration of AI in education is not without controversy. Critics argue that over-reliance on technology may diminish critical thinking skills and reduce meaningful human interaction between teachers and students. Professor Maria Chen of Cambridge University warns that "while AI can process data efficiently, it cannot replicate the emotional intelligence and mentoring capacity that human educators provide."

Furthermore, there are significant concerns about data privacy and algorithmic bias. Studies have shown that AI systems trained on biased datasets can perpetuate existing inequalities in education, potentially disadvantaging students from underrepresented backgrounds. The European Commission has called for strict regulatory frameworks to ensure that AI in education promotes equity rather than exacerbating disparities.

Despite these challenges, proponents of educational AI point to its potential for democratizing access to quality education. In developing countries, AI-powered platforms can provide world-class instruction to students in remote areas who lack access to qualified teachers. The UNESCO report on AI in education estimates that such technologies could help close the educational gap for over 250 million children worldwide who currently lack access to quality schooling.

The future of AI in education likely lies in a hybrid model that combines the efficiency of artificial intelligence with the irreplaceable human elements of teaching. As Dr. James Wright of MIT suggests, "The goal should not be to replace teachers with AI, but to empower teachers with AI tools that free them to focus on what they do best — inspiring and mentoring the next generation."''',
      questions: [
        IeltsQuestion(
          id: 'r001_q1',
          type: IeltsQuestionType.trueFalseNotGiven,
          questionText: 'AI-powered adaptive learning tools led to a 30% improvement in test scores at Stanford.',
          correctAnswer: 'True',
          options: ['True', 'False', 'Not Given'],
          explanation: 'The passage states: "Research conducted at Stanford University demonstrated that students using AI-powered adaptive learning tools showed a 30% improvement in test scores."',
          tip: 'For True/False/Not Given, focus on what the passage explicitly states. Don\'t infer beyond the text.',
        ),
        IeltsQuestion(
          id: 'r001_q2',
          type: IeltsQuestionType.trueFalseNotGiven,
          questionText: 'Professor Maria Chen supports the complete replacement of human teachers with AI.',
          correctAnswer: 'False',
          options: ['True', 'False', 'Not Given'],
          explanation: 'Professor Chen warns that AI "cannot replicate the emotional intelligence and mentoring capacity that human educators provide," implying she does NOT support complete replacement.',
          tip: 'Watch for paraphrasing. The passage implies the opposite of the statement.',
        ),
        IeltsQuestion(
          id: 'r001_q3',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'According to the passage, what is a major concern about AI in education?',
          options: [
            'A) AI systems are too expensive for most schools',
            'B) AI may perpetuate existing inequalities through biased datasets',
            'C) Students prefer traditional teaching methods',
            'D) AI technology is not reliable enough for education',
          ],
          correctAnswer: 'B',
          explanation: 'The passage states: "AI systems trained on biased datasets can perpetuate existing inequalities in education."',
          tip: 'Eliminate options not mentioned in the passage. Look for direct textual evidence.',
        ),
        IeltsQuestion(
          id: 'r001_q4',
          type: IeltsQuestionType.sentenceCompletion,
          questionText: 'UNESCO estimates AI could help close the educational gap for over _____ children worldwide.',
          correctAnswer: '250 million',
          explanation: 'The passage states: "such technologies could help close the educational gap for over 250 million children worldwide."',
          tip: 'For sentence completion, use the EXACT words or numbers from the passage.',
        ),
        IeltsQuestion(
          id: 'r001_q5',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'What does Dr. James Wright suggest about the future of AI in education?',
          options: [
            'A) AI should completely replace traditional education',
            'B) AI should be banned from classrooms',
            'C) AI should empower teachers rather than replace them',
            'D) AI is only useful in developing countries',
          ],
          correctAnswer: 'C',
          explanation: 'Dr. Wright says: "The goal should not be to replace teachers with AI, but to empower teachers with AI tools."',
          tip: 'Pay attention to quotes from experts — they often contain the answer to purpose/opinion questions.',
        ),
      ],
    ),
    IeltsReadingPassage(
      id: 'r002',
      title: 'Urban Green Spaces and Mental Health',
      source: 'Environmental Psychology Review',
      difficulty: IeltsDifficulty.band6,
      timeLimitMinutes: 20,
      passage: '''The relationship between urban green spaces and mental health has become a subject of growing interest among researchers and urban planners alike. As cities continue to expand and populations become increasingly urbanized, the importance of parks, gardens, and natural areas within urban environments has never been more evident.

A comprehensive study published in The Lancet Planetary Health examined data from over 900,000 participants across 28 countries. The findings revealed that individuals living within 300 meters of green spaces reported significantly lower levels of stress, anxiety, and depression compared to those without nearby access to nature. The effect was particularly pronounced among low-income communities, where green spaces served as free, accessible venues for physical activity and social interaction.

The mechanisms through which green spaces benefit mental health are multifaceted. Exposure to natural environments has been shown to reduce cortisol levels — the body's primary stress hormone — by up to 21% within just 20 minutes of being in a natural setting. This phenomenon, often referred to as "forest bathing" in Japanese culture (shinrin-yoku), has gained scientific backing from numerous controlled experiments.

Beyond stress reduction, green spaces promote physical activity, which itself is a well-established factor in maintaining good mental health. The World Health Organization recommends at least 150 minutes of moderate physical activity per week, and studies show that people with access to parks and green areas are 30% more likely to meet these guidelines than those without such access.

Social cohesion is another pathway through which green spaces enhance well-being. Community gardens, park events, and outdoor recreational areas create opportunities for social interaction, reducing feelings of isolation and loneliness. Research from the University of Exeter found that neighborhoods with more green space had 8% fewer reports of loneliness among residents.

However, the distribution of urban green spaces often reflects socioeconomic disparities. Wealthier neighborhoods tend to have more and better-maintained green areas, while lower-income communities frequently lack adequate access to nature. This environmental inequality has prompted calls for "green equity" policies that prioritize the creation of green spaces in underserved areas.''',
      questions: [
        IeltsQuestion(
          id: 'r002_q1',
          type: IeltsQuestionType.trueFalseNotGiven,
          questionText: 'The Lancet study included participants from more than 25 countries.',
          correctAnswer: 'True',
          options: ['True', 'False', 'Not Given'],
          explanation: 'The passage states "28 countries," which is more than 25.',
          tip: 'Be careful with numbers. "More than 25" is satisfied by "28."',
        ),
        IeltsQuestion(
          id: 'r002_q2',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'Exposure to nature can reduce cortisol levels by up to _____% within 20 minutes.',
          correctAnswer: '21',
          explanation: 'The passage states: "reduce cortisol levels... by up to 21%."',
        ),
        IeltsQuestion(
          id: 'r002_q3',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'The Japanese concept of "shinrin-yoku" refers to:',
          options: [
            'A) Urban gardening techniques',
            'B) Forest bathing for stress reduction',
            'C) Community park design principles',
            'D) Physical exercise programs in nature',
          ],
          correctAnswer: 'B',
          explanation: 'The passage explains shinrin-yoku as "forest bathing" linked to natural stress reduction.',
        ),
        IeltsQuestion(
          id: 'r002_q4',
          type: IeltsQuestionType.matchingInformation,
          questionText: 'Which section mentions the WHO recommendation for weekly physical activity?',
          correctAnswer: 'Paragraph 4',
          explanation: 'Paragraph 4 discusses the WHO recommendation of 150 minutes of moderate physical activity per week.',
          tip: 'For matching questions, scan each paragraph for specific keywords from the question.',
        ),
        IeltsQuestion(
          id: 'r002_q5',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'What does the passage suggest about the distribution of green spaces?',
          options: [
            'A) Green spaces are equally distributed across all income levels',
            'B) Lower-income areas tend to have less access to green spaces',
            'C) Only wealthy people use urban parks',
            'D) Green spaces are more common in rural areas',
          ],
          correctAnswer: 'B',
          explanation: 'The passage states: "lower-income communities frequently lack adequate access to nature."',
        ),
      ],
    ),
  ];

  // ── Listening Sections ────────────────────────────────────────────
  static const List<IeltsListeningSection> listeningSections = [
    IeltsListeningSection(
      id: 'l001',
      title: 'University Library Tour',
      description: 'A conversation between a new student and a librarian during orientation week.',
      sectionNumber: 1,
      context: 'Social conversation',
      transcript: '''Librarian: Welcome to the Central Library! I\'m Sarah. Are you a new student here?
Student: Yes, I just started this week. I\'m looking for some books for my Environmental Science course.
Librarian: Of course! Let me give you a quick tour. This floor — the ground floor — has the reference section and the computer lab. The computer lab is open from 8 AM to 10 PM on weekdays, and 9 AM to 6 PM on weekends.
Student: That\'s helpful. What about borrowing books?
Librarian: You can borrow up to 12 books at a time with your student card. The loan period is 3 weeks for regular books and 1 week for high-demand items. You can renew online through the library portal.
Student: And if I need journal articles?
Librarian: Academic journals are on the second floor. We also have online access to over 50,000 digital journals through our website. You\'ll need your student ID and password to log in remotely.
Student: Perfect. Is there a quiet study area?
Librarian: Yes, the third floor is a designated silent study zone. No phones, no talking. We also have group study rooms on the second floor that you can book online — up to 3 hours at a time.
Student: Great, thank you so much!''',
      questions: [
        IeltsQuestion(
          id: 'l001_q1',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'The computer lab closes at _____ PM on weekdays.',
          correctAnswer: '10',
          explanation: 'Sarah says the computer lab is open "from 8 AM to 10 PM on weekdays."',
          tip: 'Listen for specific times, numbers, and dates — they are frequently tested.',
        ),
        IeltsQuestion(
          id: 'l001_q2',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'Students can borrow up to _____ books at a time.',
          correctAnswer: '12',
          explanation: 'The librarian says: "You can borrow up to 12 books at a time."',
        ),
        IeltsQuestion(
          id: 'l001_q3',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'How long is the loan period for regular books?',
          options: ['A) 1 week', 'B) 2 weeks', 'C) 3 weeks', 'D) 4 weeks'],
          correctAnswer: 'C',
          explanation: 'The librarian states: "The loan period is 3 weeks for regular books."',
        ),
        IeltsQuestion(
          id: 'l001_q4',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'The library has online access to over _____ digital journals.',
          correctAnswer: '50,000',
          explanation: 'Sarah mentions "over 50,000 digital journals through our website."',
        ),
        IeltsQuestion(
          id: 'l001_q5',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'Where is the silent study zone located?',
          options: ['A) Ground floor', 'B) First floor', 'C) Second floor', 'D) Third floor'],
          correctAnswer: 'D',
          explanation: 'Sarah says: "the third floor is a designated silent study zone."',
        ),
      ],
    ),
    IeltsListeningSection(
      id: 'l002',
      title: 'Climate Change Lecture',
      description: 'An academic lecture about the effects of climate change on coastal cities.',
      sectionNumber: 4,
      context: 'Academic monologue',
      transcript: '''Good morning, class. Today we\'re going to discuss the impact of rising sea levels on coastal cities. This is one of the most pressing environmental challenges of our century.

According to the latest IPCC report, global sea levels have risen by approximately 20 centimeters since 1900, and the rate of rise is accelerating. If current trends continue, we could see an additional rise of 30 to 60 centimeters by 2100.

Now, what does this mean in practical terms? Well, approximately 40% of the world\'s population lives within 100 kilometers of the coast. Cities like Jakarta, Miami, Shanghai, and Mumbai are particularly vulnerable. Jakarta, for instance, is sinking at a rate of up to 25 centimeters per year due to a combination of rising seas and groundwater extraction.

The economic implications are staggering. A study by the Organization for Economic Cooperation and Development — the OECD — estimated that by 2070, the total value of assets exposed to coastal flooding could reach 35 trillion dollars. That\'s roughly 9% of projected global GDP.

Several adaptation strategies have been proposed. The Netherlands, which has centuries of experience managing water, has implemented an innovative approach called "Room for the River." Rather than building higher barriers, they\'ve widened floodplains and created water storage areas, working with nature rather than against it.

In conclusion, addressing sea level rise requires both mitigation — reducing greenhouse gas emissions — and adaptation — preparing communities for changes that are already inevitable. The next decade will be critical in determining which cities thrive and which face existential threats.''',
      questions: [
        IeltsQuestion(
          id: 'l002_q1',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'Sea levels have risen by approximately _____ centimeters since 1900.',
          correctAnswer: '20',
          explanation: 'The lecturer states: "global sea levels have risen by approximately 20 centimeters since 1900."',
        ),
        IeltsQuestion(
          id: 'l002_q2',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'About _____% of the world\'s population lives within 100 km of the coast.',
          correctAnswer: '40',
          explanation: 'The lecturer says: "approximately 40% of the world\'s population lives within 100 kilometers of the coast."',
        ),
        IeltsQuestion(
          id: 'l002_q3',
          type: IeltsQuestionType.multipleChoice,
          questionText: 'What is the Dutch approach to managing flooding called?',
          options: [
            'A) Higher Barriers Project',
            'B) Room for the River',
            'C) Water Defense System',
            'D) Coastal Protection Plan',
          ],
          correctAnswer: 'B',
          explanation: 'The lecturer mentions the innovative Dutch approach called "Room for the River."',
        ),
        IeltsQuestion(
          id: 'l002_q4',
          type: IeltsQuestionType.fillInBlank,
          questionText: 'By 2070, assets exposed to coastal flooding could reach _____ trillion dollars.',
          correctAnswer: '35',
          explanation: 'The OECD study estimated "35 trillion dollars."',
        ),
      ],
    ),
  ];

  // ── Writing Tasks ─────────────────────────────────────────────────
  static const List<IeltsWritingTask> writingTasks = [
    IeltsWritingTask(
      id: 'w001',
      taskNumber: 2,
      prompt: 'Some people believe that universities should focus on providing academic skills, while others think they should prepare students for employment. Discuss both views and give your own opinion.',
      description: 'Discussion Essay — Academic vs. Employment Skills',
      difficulty: IeltsDifficulty.band7,
      wordLimit: 250,
      timeLimitMinutes: 40,
      sampleOutline: [
        'Introduction: Paraphrase the topic, state both views briefly, give your thesis',
        'Body 1: Academic skills view — critical thinking, research ability, knowledge depth',
        'Body 2: Employment skills view — practical training, industry readiness, career outcomes',
        'Body 3: Your opinion — balanced approach combining both (with specific examples)',
        'Conclusion: Summarize key points, restate your position clearly',
      ],
      modelAnswer: '''It is often debated whether higher education institutions should prioritize academic knowledge or vocational training. While both perspectives have merit, I believe that a balanced approach integrating both elements produces the most well-rounded graduates.

Those who advocate for academic focus argue that universities should cultivate critical thinking, research capabilities, and deep subject knowledge. These foundational skills enable graduates to analyze complex problems, contribute to scholarly discourse, and adapt to evolving professional landscapes. For instance, a thorough grounding in scientific methodology equips students to evaluate evidence rigorously, a skill applicable across numerous careers.

Conversely, proponents of employment-oriented education contend that universities have a responsibility to prepare students for the workforce. They point to rising tuition costs and argue that graduates should possess practical competencies that employers value, such as project management, digital literacy, and communication skills. Countries like Germany, where universities closely collaborate with industry through dual education programs, demonstrate that employment-focused curricula can yield lower youth unemployment rates.

In my view, the most effective approach combines academic rigor with practical application. Universities should provide strong theoretical foundations while incorporating internships, industry projects, and skill-based workshops. This hybrid model ensures that graduates possess both the intellectual depth to innovate and the practical skills to contribute immediately in their chosen fields.

In conclusion, rather than treating academic and employment preparation as mutually exclusive, universities should strive to deliver an education that encompasses both, thereby equipping students for lifelong learning and career success.''',
      criteria: [
        IeltsWritingCriterion(name: 'Task Response', description: 'Address all parts of the task. Present a clear position.', weight: 0.25),
        IeltsWritingCriterion(name: 'Coherence & Cohesion', description: 'Organize information logically. Use paragraphing and linking devices.', weight: 0.25),
        IeltsWritingCriterion(name: 'Lexical Resource', description: 'Use a wide range of vocabulary naturally and accurately.', weight: 0.25),
        IeltsWritingCriterion(name: 'Grammatical Range & Accuracy', description: 'Use a variety of sentence structures with accuracy.', weight: 0.25),
      ],
    ),
    IeltsWritingTask(
      id: 'w002',
      taskNumber: 1,
      prompt: 'The chart below shows the percentage of households with internet access in five countries between 2000 and 2020. Summarize the information by selecting and reporting the main features, and make comparisons where relevant.',
      description: 'Task 1 — Line Chart Description (Internet Access)',
      difficulty: IeltsDifficulty.band6,
      wordLimit: 150,
      timeLimitMinutes: 20,
      sampleOutline: [
        'Introduction: Paraphrase the chart description (what, where, when)',
        'Overview: Identify 2-3 key trends (overall increase, country rankings)',
        'Detail 1: Countries with highest growth (specific data points)',
        'Detail 2: Countries with slower growth; comparisons between countries',
      ],
      modelAnswer: '''The line chart illustrates the proportion of households with internet access in five nations — South Korea, the UK, Brazil, India, and Nigeria — over a twenty-year period from 2000 to 2020.

Overall, all five countries experienced substantial growth in internet connectivity, although significant disparities remained. South Korea and the UK consistently maintained the highest rates throughout the period.

In 2000, South Korea led with approximately 45% household internet access, followed by the UK at 25%. Both countries saw rapid growth in the first decade, reaching roughly 95% and 85% respectively by 2010, before plateauing near 98% and 95% by 2020.

By contrast, Brazil, India, and Nigeria started from much lower bases — all below 5% in 2000. Brazil showed the most notable growth among this group, climbing to approximately 70% by 2020. India reached about 50%, while Nigeria trailed at around 35%, reflecting the persistent digital divide between developed and developing nations.''',
      criteria: [
        IeltsWritingCriterion(name: 'Task Achievement', description: 'Cover main trends and make comparisons.', weight: 0.25),
        IeltsWritingCriterion(name: 'Coherence & Cohesion', description: 'Organize logically with clear overview.', weight: 0.25),
        IeltsWritingCriterion(name: 'Lexical Resource', description: 'Use appropriate vocabulary for describing data.', weight: 0.25),
        IeltsWritingCriterion(name: 'Grammatical Range & Accuracy', description: 'Use a range of structures accurately.', weight: 0.25),
      ],
    ),
    IeltsWritingTask(
      id: 'w003',
      taskNumber: 2,
      prompt: 'In many countries, the number of people choosing to live alone is increasing. What are the reasons for this trend? Is this a positive or negative development?',
      description: 'Causes & Effects Essay — Living Alone Trend',
      difficulty: IeltsDifficulty.band7,
      wordLimit: 250,
      timeLimitMinutes: 40,
      sampleOutline: [
        'Introduction: Paraphrase topic, state you will discuss causes and evaluate',
        'Body 1: Reasons — financial independence, career mobility, changing social norms, technology',
        'Body 2: Positive aspects — personal freedom, self-development, reduced domestic conflict',
        'Body 3: Negative aspects — loneliness, mental health concerns, reduced family support',
        'Conclusion: It is a mixed development; benefits depend on individual circumstances',
      ],
      modelAnswer: '''The trend of increasing numbers of people living independently is evident in many nations worldwide. This essay will examine the underlying causes of this phenomenon and evaluate whether it constitutes a positive or negative development.

Several factors contribute to the rise in single-person households. Firstly, improved economic opportunities, particularly for women, have enabled more individuals to achieve financial independence, eliminating the economic necessity of cohabitation. Secondly, changing social attitudes have reduced the stigma once associated with living alone, and marriage rates have declined in many developed countries. Additionally, career mobility often requires individuals to relocate, making it impractical to maintain shared living arrangements. Finally, digital technology provides social connectivity that partially compensates for physical isolation.

There are clear benefits to this trend. Living alone affords individuals greater personal autonomy, allowing them to pursue career goals and personal interests without compromise. Research from the University of Toronto suggests that people who live alone often develop stronger public networks and more diverse social connections.

However, the negative implications cannot be overlooked. Prolonged social isolation has been linked to elevated rates of depression, anxiety, and cardiovascular disease. Furthermore, single-person households consume more resources per capita and place additional pressure on housing markets in densely populated cities.

In conclusion, the growing preference for independent living is a complex development with both advantages and drawbacks. While it reflects positive advances in personal freedom and economic empowerment, societies must address the associated risks of loneliness and its impact on mental health through community-building initiatives.''',
      criteria: [
        IeltsWritingCriterion(name: 'Task Response', description: 'Address all parts: causes + evaluation.', weight: 0.25),
        IeltsWritingCriterion(name: 'Coherence & Cohesion', description: 'Logical structure with clear progression.', weight: 0.25),
        IeltsWritingCriterion(name: 'Lexical Resource', description: 'Wide vocabulary with natural collocations.', weight: 0.25),
        IeltsWritingCriterion(name: 'Grammatical Range & Accuracy', description: 'Mix of simple and complex structures.', weight: 0.25),
      ],
    ),
  ];

  // ── Speaking Topics ───────────────────────────────────────────────
  static const List<IeltsSpeakingTopic> speakingTopics = [
    // Part 1
    IeltsSpeakingTopic(
      id: 's001',
      part: 1,
      topic: 'Hometown & Living',
      questions: [
        'Where are you from?',
        'What do you like most about your hometown?',
        'Has your hometown changed much in recent years?',
        'Would you prefer to live in a city or in the countryside? Why?',
      ],
      sampleAnswerPoints: [
        'Mention specific features: landmarks, atmosphere, food, culture',
        'Use present perfect for changes: "It has become more modern..."',
        'Give reasons with examples: "I prefer the city because..."',
        'Show range: use comparatives, conditionals, would/could',
      ],
      vocabularyTips: [
        'bustling, vibrant, tranquil, picturesque',
        'outskirts, suburbs, metropolitan area',
        'has undergone significant changes',
        'a close-knit community, culturally diverse',
      ],
      grammarTips: [
        'Use present perfect for changes over time',
        'Mix simple and complex sentences',
        'Use "would" for hypothetical preferences',
      ],
    ),
    IeltsSpeakingTopic(
      id: 's002',
      part: 1,
      topic: 'Technology & Internet',
      questions: [
        'How often do you use the internet?',
        'What do you mainly use it for?',
        'Do you think children should have limited screen time?',
        'How has technology changed the way people communicate?',
      ],
      sampleAnswerPoints: [
        'Be specific about usage: "I use it daily for research and social media"',
        'Give balanced answers: acknowledge both benefits and drawbacks',
        'Use frequency adverbs: constantly, occasionally, seldom',
        'Compare past and present when discussing changes',
      ],
      vocabularyTips: [
        'stay connected, digital literacy, screen time',
        'social media platforms, streaming services',
        'online learning, remote working',
        'instant messaging, video conferencing',
      ],
      grammarTips: [
        'Use present simple for habits and routines',
        'Compare using "whereas" and "while" for contrast',
        'Use "used to" for past habits vs. present reality',
      ],
    ),
    // Part 2
    IeltsSpeakingTopic(
      id: 's003',
      part: 2,
      topic: 'Describe a Book You Recently Read',
      cueCard: '''Describe a book you recently read that you found interesting.

You should say:
  • what the book was about
  • why you decided to read it
  • what you learned from it
and explain why you found it interesting.''',
      thinkTimeSeconds: 60,
      speakTimeSeconds: 120,
      questions: [
        'Describe the book and its main theme',
        'Explain your motivation for reading it',
        'Share what you learned',
        'Explain why it was interesting to you',
      ],
      sampleAnswerPoints: [
        'Name the book and author clearly',
        'Structure: introduction → content → personal reflection',
        'Use past tense for the story, present tense for opinions',
        'Include at least one specific example or quote from the book',
        'End with a strong concluding statement about its impact on you',
      ],
      vocabularyTips: [
        'page-turner, thought-provoking, compelling narrative',
        'the author vividly describes, the plot revolves around',
        'I was particularly struck by, it resonated with me',
        'I would highly recommend it to anyone interested in...',
      ],
      grammarTips: [
        'Use past simple for the plot: "The story followed..."',
        'Use present simple for your opinions: "I believe..."',
        'Include relative clauses: "which made me realize..."',
      ],
    ),
    // Part 3
    IeltsSpeakingTopic(
      id: 's004',
      part: 3,
      topic: 'Education & Learning',
      questions: [
        'How has education changed in your country compared to the past?',
        'Do you think online learning can replace traditional classroom teaching?',
        'What skills do you think are most important for young people to learn today?',
        'Should education focus more on practical skills or academic knowledge?',
      ],
      sampleAnswerPoints: [
        'Give extended, developed answers (not just yes/no)',
        'Use hedging language: "It seems to me that...", "I would argue that..."',
        'Provide examples from your country or personal experience',
        'Show ability to discuss abstract concepts and hypotheticals',
        'Acknowledge different perspectives before stating your opinion',
      ],
      vocabularyTips: [
        'curriculum reform, lifelong learning, digital literacy',
        'rote learning vs. critical thinking',
        'vocational training, tertiary education',
        'pedagogical approaches, student-centered learning',
      ],
      grammarTips: [
        'Use conditional structures: "If governments invested more..."',
        'Show range with passive voice: "Education is often regarded as..."',
        'Use discourse markers: furthermore, however, consequently',
      ],
    ),
  ];

  // ── Academic Vocabulary (AWL-based, IELTS high-frequency) ─────────
  static const List<IeltsVocabulary> academicVocabulary = [
    IeltsVocabulary(
      word: 'analyze',
      partOfSpeech: 'verb',
      definition: 'To examine something methodically and in detail',
      exampleSentence: 'The researchers analyzed the data from over 500 participants.',
      ieltsContext: 'Academic Writing & Reading',
      synonyms: ['examine', 'investigate', 'evaluate', 'assess'],
      collocations: ['analyze data', 'critically analyze', 'analyze trends'],
      bandLevel: IeltsDifficulty.band6,
    ),
    IeltsVocabulary(
      word: 'subsequently',
      partOfSpeech: 'adverb',
      definition: 'After a particular thing has happened; afterwards',
      exampleSentence: 'The company expanded rapidly and subsequently became a market leader.',
      ieltsContext: 'Writing Task 1 & Academic Reading',
      synonyms: ['afterwards', 'later', 'consequently', 'thereafter'],
      collocations: ['subsequently led to', 'subsequently increased'],
      bandLevel: IeltsDifficulty.band7,
    ),
    IeltsVocabulary(
      word: 'significant',
      partOfSpeech: 'adjective',
      definition: 'Sufficiently great or important to be worthy of attention',
      exampleSentence: 'There was a significant increase in sales during the second quarter.',
      ieltsContext: 'Writing Task 1 & Task 2',
      synonyms: ['considerable', 'substantial', 'notable', 'marked'],
      collocations: ['significant increase', 'significant impact', 'statistically significant'],
      bandLevel: IeltsDifficulty.band6,
    ),
    IeltsVocabulary(
      word: 'prevalent',
      partOfSpeech: 'adjective',
      definition: 'Widespread in a particular area or at a particular time',
      exampleSentence: 'Obesity is becoming increasingly prevalent in developed nations.',
      ieltsContext: 'Academic Reading & Writing',
      synonyms: ['widespread', 'common', 'pervasive', 'ubiquitous'],
      collocations: ['increasingly prevalent', 'prevalent in', 'prevalent among'],
      bandLevel: IeltsDifficulty.band7,
    ),
    IeltsVocabulary(
      word: 'mitigate',
      partOfSpeech: 'verb',
      definition: 'To make less severe, serious, or painful',
      exampleSentence: 'Governments must take steps to mitigate the effects of climate change.',
      ieltsContext: 'Writing Task 2 & Speaking Part 3',
      synonyms: ['alleviate', 'reduce', 'lessen', 'diminish'],
      collocations: ['mitigate risks', 'mitigate the impact', 'mitigate effects'],
      bandLevel: IeltsDifficulty.band8,
    ),
    IeltsVocabulary(
      word: 'albeit',
      partOfSpeech: 'conjunction',
      definition: 'Although; even though',
      exampleSentence: 'The project was successful, albeit slightly over budget.',
      ieltsContext: 'Academic Writing',
      synonyms: ['although', 'even though', 'though'],
      collocations: ['albeit briefly', 'albeit slowly', 'albeit with some limitations'],
      bandLevel: IeltsDifficulty.band8,
    ),
    IeltsVocabulary(
      word: 'facilitate',
      partOfSpeech: 'verb',
      definition: 'To make an action or process easier',
      exampleSentence: 'Technology has facilitated communication across borders.',
      ieltsContext: 'Writing & Speaking',
      synonyms: ['enable', 'assist', 'promote', 'expedite'],
      collocations: ['facilitate learning', 'facilitate growth', 'facilitate communication'],
      bandLevel: IeltsDifficulty.band7,
    ),
    IeltsVocabulary(
      word: 'deteriorate',
      partOfSpeech: 'verb',
      definition: 'To become progressively worse',
      exampleSentence: 'Air quality in major cities continues to deteriorate.',
      ieltsContext: 'Writing & Reading',
      synonyms: ['decline', 'worsen', 'degrade', 'degenerate'],
      collocations: ['rapidly deteriorate', 'deteriorate over time', 'conditions deteriorate'],
      bandLevel: IeltsDifficulty.band7,
    ),
    IeltsVocabulary(
      word: 'exacerbate',
      partOfSpeech: 'verb',
      definition: 'To make a problem, situation, or negative feeling worse',
      exampleSentence: 'The economic crisis was exacerbated by poor government policies.',
      ieltsContext: 'Academic Writing & Reading',
      synonyms: ['worsen', 'aggravate', 'intensify', 'compound'],
      collocations: ['exacerbate the problem', 'exacerbate inequality', 'further exacerbate'],
      bandLevel: IeltsDifficulty.band8,
    ),
    IeltsVocabulary(
      word: 'juxtapose',
      partOfSpeech: 'verb',
      definition: 'To place close together for contrasting effect',
      exampleSentence: 'The author juxtaposes rural simplicity with urban complexity.',
      ieltsContext: 'Academic Writing & Reading',
      synonyms: ['contrast', 'compare', 'set side by side'],
      collocations: ['juxtapose ideas', 'juxtapose images', 'juxtaposed with'],
      bandLevel: IeltsDifficulty.band9,
    ),
    IeltsVocabulary(
      word: 'paradigm',
      partOfSpeech: 'noun',
      definition: 'A typical example or pattern of something; a model',
      exampleSentence: 'The digital revolution has created a paradigm shift in how we access information.',
      ieltsContext: 'Academic Reading & Writing',
      synonyms: ['model', 'framework', 'pattern', 'archetype'],
      collocations: ['paradigm shift', 'new paradigm', 'dominant paradigm'],
      bandLevel: IeltsDifficulty.band8,
    ),
    IeltsVocabulary(
      word: 'phenomenon',
      partOfSpeech: 'noun',
      definition: 'A fact or situation that is observed to exist or happen',
      exampleSentence: 'Urbanization is a global phenomenon affecting both developed and developing countries.',
      ieltsContext: 'Writing & Speaking',
      synonyms: ['occurrence', 'event', 'trend', 'development'],
      collocations: ['natural phenomenon', 'global phenomenon', 'widespread phenomenon'],
      bandLevel: IeltsDifficulty.band7,
    ),
    IeltsVocabulary(
      word: 'unprecedented',
      partOfSpeech: 'adjective',
      definition: 'Never done or known before',
      exampleSentence: 'The pandemic caused unprecedented disruption to global supply chains.',
      ieltsContext: 'Writing Task 2 & Reading',
      synonyms: ['unparalleled', 'unmatched', 'extraordinary', 'exceptional'],
      collocations: ['unprecedented growth', 'unprecedented levels', 'unprecedented challenges'],
      bandLevel: IeltsDifficulty.band8,
    ),
    IeltsVocabulary(
      word: 'inherent',
      partOfSpeech: 'adjective',
      definition: 'Existing in something as a permanent, essential, or characteristic attribute',
      exampleSentence: 'There are inherent risks in any investment strategy.',
      ieltsContext: 'Academic Writing & Reading',
      synonyms: ['intrinsic', 'innate', 'built-in', 'fundamental'],
      collocations: ['inherent risk', 'inherent weakness', 'inherent in'],
      bandLevel: IeltsDifficulty.band8,
    ),
    IeltsVocabulary(
      word: 'empirical',
      partOfSpeech: 'adjective',
      definition: 'Based on observation or experience rather than theory',
      exampleSentence: 'The study provides empirical evidence to support the hypothesis.',
      ieltsContext: 'Academic Reading & Writing',
      synonyms: ['observational', 'experimental', 'evidence-based', 'practical'],
      collocations: ['empirical evidence', 'empirical research', 'empirical data'],
      bandLevel: IeltsDifficulty.band9,
    ),
    IeltsVocabulary(
      word: 'fluctuate',
      partOfSpeech: 'verb',
      definition: 'To rise and fall irregularly in number or amount',
      exampleSentence: 'Oil prices fluctuated dramatically throughout the year.',
      ieltsContext: 'Writing Task 1',
      synonyms: ['vary', 'oscillate', 'swing', 'waver'],
      collocations: ['fluctuate between', 'fluctuate wildly', 'prices fluctuate'],
      bandLevel: IeltsDifficulty.band6,
    ),
  ];

  // ── IELTS Mini Games ──────────────────────────────────────────────
  static const List<IeltsMiniGame> miniGames = [
    IeltsMiniGame(
      id: 'g001',
      type: IeltsGameType.synonymMatch,
      title: 'Synonym Sprint',
      description: 'Match academic words to their synonyms before time runs out!',
      iconName: 'sync_alt',
      difficulty: IeltsDifficulty.band6,
      durationSeconds: 90,
    ),
    IeltsMiniGame(
      id: 'g002',
      type: IeltsGameType.wordScramble,
      title: 'Word Unscramble',
      description: 'Unscramble IELTS academic vocabulary words!',
      iconName: 'shuffle',
      difficulty: IeltsDifficulty.band6,
      durationSeconds: 120,
    ),
    IeltsMiniGame(
      id: 'g003',
      type: IeltsGameType.sentenceBuilder,
      title: 'Sentence Architect',
      description: 'Build grammatically correct sentences by arranging words in order.',
      iconName: 'construction',
      difficulty: IeltsDifficulty.band7,
      durationSeconds: 150,
    ),
    IeltsMiniGame(
      id: 'g004',
      type: IeltsGameType.errorSpotting,
      title: 'Error Detective',
      description: 'Find and fix grammar and vocabulary errors in IELTS-style sentences.',
      iconName: 'bug_report',
      difficulty: IeltsDifficulty.band7,
      durationSeconds: 120,
    ),
    IeltsMiniGame(
      id: 'g005',
      type: IeltsGameType.collocationsMatch,
      title: 'Collocation Connect',
      description: 'Match words that naturally go together in academic English.',
      iconName: 'link',
      difficulty: IeltsDifficulty.band7,
      durationSeconds: 90,
    ),
    IeltsMiniGame(
      id: 'g006',
      type: IeltsGameType.bandPredictor,
      title: 'Band Predictor Quiz',
      description: 'Answer mixed IELTS questions and predict your band score!',
      iconName: 'analytics',
      difficulty: IeltsDifficulty.band6,
      durationSeconds: 300,
    ),
  ];

  // ── Score calculation helpers ─────────────────────────────────────

  /// Convert raw reading score (out of 40) to band score.
  static double readingRawToBand(int correct) {
    if (correct >= 39) return 9.0;
    if (correct >= 37) return 8.5;
    if (correct >= 35) return 8.0;
    if (correct >= 33) return 7.5;
    if (correct >= 30) return 7.0;
    if (correct >= 27) return 6.5;
    if (correct >= 23) return 6.0;
    if (correct >= 19) return 5.5;
    if (correct >= 15) return 5.0;
    if (correct >= 13) return 4.5;
    if (correct >= 10) return 4.0;
    if (correct >= 8) return 3.5;
    if (correct >= 6) return 3.0;
    if (correct >= 4) return 2.5;
    return 2.0;
  }

  /// Convert raw listening score (out of 40) to band score.
  static double listeningRawToBand(int correct) {
    if (correct >= 39) return 9.0;
    if (correct >= 37) return 8.5;
    if (correct >= 35) return 8.0;
    if (correct >= 32) return 7.5;
    if (correct >= 30) return 7.0;
    if (correct >= 26) return 6.5;
    if (correct >= 23) return 6.0;
    if (correct >= 18) return 5.5;
    if (correct >= 16) return 5.0;
    if (correct >= 13) return 4.5;
    if (correct >= 11) return 4.0;
    if (correct >= 8) return 3.5;
    if (correct >= 6) return 3.0;
    if (correct >= 4) return 2.5;
    return 2.0;
  }

  /// Calculate overall band score from 4 section scores.
  static double calculateOverallBand(double reading, double listening, double writing, double speaking) {
    final raw = (reading + listening + writing + speaking) / 4;
    return (raw * 2).round() / 2; // Round to nearest 0.5
  }

  // ── Synonym game data ─────────────────────────────────────────────
  static const List<Map<String, String>> synonymPairs = [
    {'word': 'significant', 'synonym': 'substantial'},
    {'word': 'prevalent', 'synonym': 'widespread'},
    {'word': 'mitigate', 'synonym': 'alleviate'},
    {'word': 'facilitate', 'synonym': 'enable'},
    {'word': 'deteriorate', 'synonym': 'decline'},
    {'word': 'exacerbate', 'synonym': 'worsen'},
    {'word': 'unprecedented', 'synonym': 'unparalleled'},
    {'word': 'inherent', 'synonym': 'intrinsic'},
    {'word': 'fluctuate', 'synonym': 'vary'},
    {'word': 'paradigm', 'synonym': 'framework'},
    {'word': 'analyze', 'synonym': 'examine'},
    {'word': 'subsequently', 'synonym': 'afterwards'},
    {'word': 'phenomenon', 'synonym': 'occurrence'},
    {'word': 'empirical', 'synonym': 'observational'},
    {'word': 'albeit', 'synonym': 'although'},
  ];

  // ── Error spotting game data ──────────────────────────────────────
  static const List<Map<String, String>> errorSpottingData = [
    {
      'sentence': 'The number of students have increased significantly.',
      'error': 'have',
      'correction': 'has',
      'rule': 'Subject-verb agreement: "number" is singular.',
    },
    {
      'sentence': 'She is more smarter than her classmates.',
      'error': 'more smarter',
      'correction': 'smarter',
      'rule': 'Double comparative: use either "more" or "-er", not both.',
    },
    {
      'sentence': 'The datas show a clear upward trend.',
      'error': 'datas',
      'correction': 'data',
      'rule': '"Data" is already plural (singular: datum). No "s" needed.',
    },
    {
      'sentence': 'Despite of the challenges, the project succeeded.',
      'error': 'Despite of',
      'correction': 'Despite',
      'rule': '"Despite" is not followed by "of". Use "in spite of" instead.',
    },
    {
      'sentence': 'The chart shows that there was a dramatical increase.',
      'error': 'dramatical',
      'correction': 'dramatic',
      'rule': 'The correct adjective form is "dramatic", not "dramatical".',
    },
    {
      'sentence': 'Many people believes that education is important.',
      'error': 'believes',
      'correction': 'believe',
      'rule': 'Subject-verb agreement: "people" is plural, so use "believe".',
    },
    {
      'sentence': 'The informations provided were very useful.',
      'error': 'informations',
      'correction': 'information',
      'rule': '"Information" is an uncountable noun. It cannot be pluralized.',
    },
    {
      'sentence': 'He gave an advice to his younger brother.',
      'error': 'an advice',
      'correction': 'some advice / a piece of advice',
      'rule': '"Advice" is uncountable. Use "some advice" or "a piece of advice".',
    },
  ];

  // ── Collocation data ──────────────────────────────────────────────
  static const List<Map<String, String>> collocationPairs = [
    {'first': 'make', 'second': 'a decision'},
    {'first': 'conduct', 'second': 'research'},
    {'first': 'draw', 'second': 'a conclusion'},
    {'first': 'pose', 'second': 'a threat'},
    {'first': 'raise', 'second': 'awareness'},
    {'first': 'pay', 'second': 'attention'},
    {'first': 'take', 'second': 'into account'},
    {'first': 'reach', 'second': 'a consensus'},
    {'first': 'implement', 'second': 'a policy'},
    {'first': 'address', 'second': 'an issue'},
    {'first': 'undergo', 'second': 'a transformation'},
    {'first': 'yield', 'second': 'results'},
  ];

  // ── Sentence builder data ─────────────────────────────────────────
  static const List<Map<String, dynamic>> sentenceBuilderData = [
    {
      'correct': 'The government should implement stricter regulations to protect the environment.',
      'words': ['The', 'government', 'should', 'implement', 'stricter', 'regulations', 'to', 'protect', 'the', 'environment.'],
    },
    {
      'correct': 'It is widely acknowledged that education plays a crucial role in economic development.',
      'words': ['It', 'is', 'widely', 'acknowledged', 'that', 'education', 'plays', 'a', 'crucial', 'role', 'in', 'economic', 'development.'],
    },
    {
      'correct': 'The rapid growth of technology has significantly transformed modern society.',
      'words': ['The', 'rapid', 'growth', 'of', 'technology', 'has', 'significantly', 'transformed', 'modern', 'society.'],
    },
    {
      'correct': 'Despite the obvious benefits, there are inherent risks associated with globalization.',
      'words': ['Despite', 'the', 'obvious', 'benefits,', 'there', 'are', 'inherent', 'risks', 'associated', 'with', 'globalization.'],
    },
  ];
}
